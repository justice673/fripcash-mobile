{{flutter_js}}
{{flutter_build_config}}

(function () {
  var isWebKit =
    navigator.vendor === "Apple Computer, Inc." ||
    /iPhone|iPad|iPod/i.test(navigator.userAgent);

  _flutter.loader.load({
    serviceWorkerSettings: {
      // Skip service worker on mobile ngrok — stale caches break large downloads.
      serviceWorkerUrl: isWebKit ? null : undefined,
      timeoutMillis: isWebKit ? 120000 : 4000,
    },
    config: {
      // Safari/iOS only supports the full CanvasKit build — not chromium.
      canvasKitVariant: "full",
      canvasKitForceMultiSurfaceRasterizer: !isWebKit,
    },
  });
})();
