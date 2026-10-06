import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/dom_file_pick_stub.dart'
    if (dart.library.html) 'package:frip_cash/widgets/dom_file_pick_web.dart'
    as dom_pick;
import 'package:image_picker/image_picker.dart';

/// Opens gallery or camera. On web, uses a real HTML file input overlay so the
/// browser file dialog is not blocked by Flutter's pointer routing.
Future<List<XFile>?> showAddPhotosSheet(
  BuildContext context, {
  required int maxPhotos,
}) {
  return showModalBottomSheet<List<XFile>>(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => _AddPhotosSheet(maxPhotos: maxPhotos),
  );
}

class _AddPhotosSheet extends StatefulWidget {
  const _AddPhotosSheet({required this.maxPhotos});

  final int maxPhotos;

  @override
  State<_AddPhotosSheet> createState() => _AddPhotosSheetState();
}

class _AddPhotosSheetState extends State<_AddPhotosSheet> {
  bool _busy = false;

  void _returnFiles(List<XFile> files) {
    if (!mounted || files.isEmpty) return;
    final limited = files.take(widget.maxPhotos).toList(growable: false);
    Navigator.pop(context, limited);
  }

  Future<void> _pickNative(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);

    final picker = ImagePicker();
    try {
      final List<XFile> picked;
      if (source == ImageSource.gallery) {
        if (widget.maxPhotos <= 1) {
          final one = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
          picked = one == null ? const <XFile>[] : <XFile>[one];
        } else {
          picked = await picker.pickMultiImage(
            imageQuality: 85,
            limit: widget.maxPhotos,
          );
        }
      } else {
        final shot = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        picked = shot == null ? const <XFile>[] : <XFile>[shot];
      }
      if (!mounted) return;
      if (picked.isEmpty) {
        setState(() => _busy = false);
        return;
      }
      Navigator.pop(context, picked.take(widget.maxPhotos).toList());
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? AppLocalizations.of(context)!.uploadPhotos),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                ),
                Text(
                  t.addPhotosTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _AddTile(
                    icon: Icons.photo_library_outlined,
                    label: t.uploadPhotos,
                    webOverlay: kIsWeb
                        ? dom_pick.buildDomFilePickOverlay(
                            viewType: 'frip-photo-gallery',
                            multiple: true,
                            camera: false,
                            onPicked: _returnFiles,
                          )
                        : null,
                    onTap: kIsWeb
                        ? null
                        : () => _pickNative(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AddTile(
                    icon: Icons.photo_camera_outlined,
                    label: t.cameraLabel,
                    webOverlay: kIsWeb
                        ? dom_pick.buildDomFilePickOverlay(
                            viewType: 'frip-photo-camera',
                            multiple: false,
                            camera: true,
                            onPicked: _returnFiles,
                          )
                        : null,
                    onTap: kIsWeb
                        ? null
                        : () => _pickNative(ImageSource.camera),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.webOverlay,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? webOverlay;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );

    if (webOverlay != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            content,
            Positioned.fill(child: webOverlay!),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: content,
      ),
    );
  }
}
