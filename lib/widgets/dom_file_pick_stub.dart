import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// Non-web stub — real overlay lives in `dom_file_pick_web.dart`.
Widget buildDomFilePickOverlay({
  required String viewType,
  required bool multiple,
  required bool camera,
  required void Function(List<XFile> files) onPicked,
}) {
  return const SizedBox.expand();
}

void registerDomFilePickViewFactory({
  required String viewType,
  required bool multiple,
  required bool camera,
  required void Function(List<XFile> files) onPicked,
}) {}
