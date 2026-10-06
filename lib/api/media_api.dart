import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/cloudinary_upload.dart';

class UploadedMedia {
  const UploadedMedia({
    required this.publicId,
    required this.url,
    this.mimeType = 'image/jpeg',
  });

  final String publicId;
  final String url;
  final String mimeType;
}

class MediaApi {
  MediaApi._();
  static final MediaApi instance = MediaApi._();

  final _client = ApiClient.instance;

  Future<UploadedMedia> uploadBytes({
    required Uint8List bytes,
    String filename = 'photo.jpg',
    String mimeType = 'image/jpeg',
  }) async {
    return uploadCloudinaryBytes(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
      folder: 'listings',
    );
  }

  /// Authenticated Cloudinary upload via `POST /media/cloudinary-sign`.
  Future<UploadedMedia> uploadCloudinaryBytes({
    required Uint8List bytes,
    String filename = 'photo.jpg',
    String mimeType = 'image/jpeg',
    String folder = 'listings',
  }) async {
    try {
      final signRes = await _client.post<Map<String, dynamic>>(
        '/media/cloudinary-sign',
        data: {'folder': folder},
      );
      final sign = Map<String, dynamic>.from(signRes.data ?? {});
      final uploaded = await uploadCloudinarySigned(
        sign: sign,
        bytes: bytes,
        filename: filename,
      );
      return UploadedMedia(
        publicId: uploaded.publicId,
        url: uploaded.url,
        mimeType: mimeType,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Shop logo for become-seller — Cloudinary public_id required by Nest.
  Future<String> uploadShopLogo({
    required Uint8List bytes,
    String filename = 'logo.jpg',
    String mimeType = 'image/jpeg',
  }) async {
    final media = await uploadCloudinaryBytes(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
      folder: 'listings',
    );
    return media.publicId;
  }

  /// Accepts `https://…` or `data:image/…;base64,…` from the sell wizard.
  Future<UploadedMedia?> uploadPhotoSource(String source) async {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      final id = source.split('/').last.split('?').first;
      return UploadedMedia(
        publicId: id.isEmpty ? 'remote_${source.hashCode.abs()}' : id,
        url: source,
      );
    }
    if (source.startsWith('data:')) {
      final match = RegExp(
        r'^data:([^;]+);base64,(.+)$',
        dotAll: true,
      ).firstMatch(source);
      if (match == null) return null;
      final mime = match.group(1) ?? 'image/jpeg';
      final b64 = match.group(2)!;
      final bytes = base64Decode(b64);
      final ext = mime.contains('png')
          ? 'png'
          : mime.contains('webp')
              ? 'webp'
              : 'jpg';
      return uploadBytes(
        bytes: bytes,
        filename: 'listing.$ext',
        mimeType: mime,
      );
    }
    return null;
  }
}
