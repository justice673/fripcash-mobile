import 'dart:convert';
import 'dart:typed_data';

import 'package:frip_cash/api/api_client.dart';
import 'package:http/http.dart' as http;

/// Upload bytes to Cloudinary using a Nest sign payload.
///
/// Nest returns camelCase (`apiKey`, `cloudName`, `uploadUrl`); Cloudinary
/// expects snake_case form fields (`api_key`, `timestamp`, `signature`, `folder`).
Future<({String publicId, String url})> uploadCloudinarySigned({
  required Map<String, dynamic> sign,
  required Uint8List bytes,
  String filename = 'photo.jpg',
}) async {
  final apiUrl = (sign['uploadUrl'] ??
          sign['url'] ??
          (() {
            final cloudName =
                (sign['cloudName'] ?? sign['cloud_name'] ?? '').toString();
            return cloudName.isNotEmpty
                ? 'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
                : '';
          })())
      .toString();
  final apiKey = (sign['apiKey'] ?? sign['api_key'] ?? '').toString();
  final timestamp = (sign['timestamp'] ?? '').toString();
  final signature = (sign['signature'] ?? '').toString();
  final folder = (sign['folder'] ?? '').toString();

  if (apiUrl.isEmpty ||
      apiKey.isEmpty ||
      timestamp.isEmpty ||
      signature.isEmpty ||
      folder.isEmpty) {
    throw ApiException(
      code: 'CLOUDINARY_SIGN_INVALID',
      message: 'Incomplete Cloudinary sign response',
    );
  }

  final req = http.MultipartRequest('POST', Uri.parse(apiUrl));
  req.fields['api_key'] = apiKey;
  req.fields['timestamp'] = timestamp;
  req.fields['signature'] = signature;
  req.fields['folder'] = folder;
  req.files.add(
    http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    ),
  );

  final streamed = await req.send();
  final body = await streamed.stream.bytesToString();
  if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
    throw ApiException(
      code: 'CLOUDINARY_UPLOAD_FAILED',
      message: _cloudinaryErrorMessage(body),
      statusCode: streamed.statusCode,
    );
  }

  final decoded = jsonDecode(body);
  if (decoded is! Map) {
    throw ApiException(
      code: 'CLOUDINARY_UPLOAD_FAILED',
      message: 'Unexpected Cloudinary response',
    );
  }
  final publicId = (decoded['public_id'] ?? '').toString();
  final url = (decoded['secure_url'] ?? decoded['url'] ?? '').toString();
  if (publicId.isEmpty) {
    throw ApiException(
      code: 'CLOUDINARY_UPLOAD_FAILED',
      message: 'No public_id in upload response',
    );
  }
  return (publicId: publicId, url: url.isNotEmpty ? url : publicId);
}

String _cloudinaryErrorMessage(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final err = decoded['error'];
      if (err is Map && err['message'] != null) {
        return err['message'].toString();
      }
      if (decoded['message'] != null) {
        return decoded['message'].toString();
      }
    }
  } catch (_) {
    // Fall through to raw body.
  }
  return body.length > 200 ? '${body.substring(0, 200)}…' : body;
}
