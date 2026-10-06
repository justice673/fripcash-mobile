import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web/web.dart' as web;

final Set<String> _registeredViewTypes = <String>{};
final Map<String, void Function(List<XFile> files)> _callbacks =
    <String, void Function(List<XFile> files)>{};

void registerDomFilePickViewFactory({
  required String viewType,
  required bool multiple,
  required bool camera,
  required void Function(List<XFile> files) onPicked,
}) {
  _callbacks[viewType] = onPicked;
  if (_registeredViewTypes.contains(viewType)) return;
  _registeredViewTypes.add(viewType);

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = 'image/*'
      ..multiple = multiple
      ..title = ''
      ..style.opacity = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.cursor = 'pointer'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0'
      ..style.margin = '0'
      ..style.padding = '0'
      ..style.border = '0'
      ..style.fontSize = '0';

    if (camera) {
      input.setAttribute('capture', 'environment');
    }

    input.addEventListener(
      'change',
      (web.Event _) {
        unawaited(_handleChange(viewType, input));
      }.toJS,
    );

    final host = web.HTMLDivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative'
      ..style.overflow = 'hidden';
    host.append(input);
    return host;
  });
}

Future<void> _handleChange(String viewType, web.HTMLInputElement input) async {
  final list = input.files;
  if (list == null || list.length == 0) {
    input.value = '';
    return;
  }

  final files = <XFile>[];
  for (var i = 0; i < list.length; i++) {
    final file = list.item(i);
    if (file == null) continue;
    final bytes = await _readFileBytes(file);
    if (bytes.isEmpty) continue;
    files.add(
      XFile.fromData(
        bytes,
        mimeType: file.type.isEmpty ? 'image/jpeg' : file.type,
        name: file.name,
      ),
    );
  }

  input.value = '';
  if (files.isNotEmpty) {
    _callbacks[viewType]?.call(files);
  }
}

Future<Uint8List> _readFileBytes(web.File file) async {
  final buffer = await file.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}

Widget buildDomFilePickOverlay({
  required String viewType,
  required bool multiple,
  required bool camera,
  required void Function(List<XFile> files) onPicked,
}) {
  registerDomFilePickViewFactory(
    viewType: viewType,
    multiple: multiple,
    camera: camera,
    onPicked: onPicked,
  );
  return HtmlElementView(viewType: viewType);
}
