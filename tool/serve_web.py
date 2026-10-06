#!/usr/bin/env python3
"""Static file server with gzip for large Flutter web assets."""

from __future__ import annotations

import gzip
import io
import mimetypes
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "build" / "web"
COMPRESS_MIN_BYTES = 1024
COMPRESS_TYPES = {
    ".js",
    ".wasm",
    ".json",
    ".svg",
    ".html",
    ".css",
    ".dart.js",
}


class GzipStaticHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self) -> None:
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

    def guess_type(self, path: str) -> str:
        ctype, _ = mimetypes.guess_type(path)
        if path.endswith(".wasm"):
            return "application/wasm"
        if path.endswith(".js"):
            return "text/javascript"
        return ctype or "application/octet-stream"

    def send_head(self):
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            return super().send_head()

        if not os.path.isfile(path):
            self.send_error(404, "File not found")
            return None

        ctype = self.guess_type(path)
        accept_encoding = self.headers.get("Accept-Encoding", "")
        use_gzip = (
            "gzip" in accept_encoding
            and os.path.getsize(path) >= COMPRESS_MIN_BYTES
            and any(path.endswith(ext) for ext in COMPRESS_TYPES)
        )

        try:
            with open(path, "rb") as src:
                raw = src.read()
        except OSError:
            self.send_error(404, "File not found")
            return None

        body = raw
        encoding = None
        if use_gzip:
            buf = io.BytesIO()
            with gzip.GzipFile(fileobj=buf, mode="wb", compresslevel=6) as gz:
                gz.write(raw)
            body = buf.getvalue()
            encoding = "gzip"

        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        if encoding:
            self.send_header("Content-Encoding", encoding)
            self.send_header("Vary", "Accept-Encoding")
        self.end_headers()
        return io.BytesIO(body)


def main() -> None:
    host = "0.0.0.0"
    port = 8080
    server = ThreadingHTTPServer((host, port), GzipStaticHandler)
    print(f"Serving {ROOT} on http://{host}:{port} (gzip enabled)")
    server.serve_forever()


if __name__ == "__main__":
    main()
