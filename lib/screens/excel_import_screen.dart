import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/widgets/capability_gate.dart';
import 'package:frip_cash/widgets/pill_button.dart';
import 'package:path_provider/path_provider.dart';

class ExcelImportScreen extends StatefulWidget {
  const ExcelImportScreen({super.key});

  @override
  State<ExcelImportScreen> createState() => _ExcelImportScreenState();
}

class _ExcelImportScreenState extends State<ExcelImportScreen> {
  bool _busy = false;
  bool _metaLoading = true;
  String? _metaError;
  String? _selectedName;
  ExcelImportMeta? _meta;
  List<ExcelImportError> _errors = const [];

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    setState(() {
      _metaLoading = true;
      _metaError = null;
    });
    try {
      final meta = await ListingsApi.instance.fetchExcelImportMeta();
      if (!mounted) return;
      setState(() {
        _meta = meta;
        _metaLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _meta = null;
        _metaLoading = false;
        _metaError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _meta = null;
        _metaLoading = false;
        _metaError = e.toString();
      });
    }
  }

  Future<void> _downloadTemplate() async {
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final bytes = await ListingsApi.instance.downloadExcelTemplate();
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/fripcash_catalogue_template.xlsx';
      await File(path).writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.excelTemplateSaved(path)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final t = AppLocalizations.of(context);
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls'],
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.noFileSelected),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _busy = true;
      _selectedName = file.name;
      _errors = const [];
    });
    try {
      final imported = await ListingsApi.instance.uploadExcelImport(
        bytes: bytes,
        filename: file.name,
      );
      if (!mounted) return;
      setState(() => _errors = imported.errors);
      await _loadMeta();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.excelImportSuccess(
              imported.imported,
              imported.updated,
              imported.failed,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lastLabel = _meta?.lastFileName ??
        (_meta?.lastImportAt != null
            ? _meta!.lastImportAt!.toIso8601String()
            : null);
    return CapabilityGate(
      allowed: canAccessExcelImport,
      title: t.sellerOnlyAreaTitle,
      message: t.importExcelSubtitle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: Text(
            t.excelImportTitle,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                t.excelImportSubtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              if (_metaLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                )
              else if (_metaError != null)
                Text(
                  _metaError!,
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                )
              else if (lastLabel != null)
                Text(
                  t.excelLastImport(lastLabel),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _busy ? null : _downloadTemplate,
                icon: const Icon(Icons.download_outlined),
                label: Text(t.downloadExcelTemplate),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 48,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedName ?? t.noFileSelected,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.dragOrSelectFile,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PillPrimaryButton(
                      label: _busy ? t.importInProgress : t.chooseFile,
                      onPressed: _busy ? null : _pickAndUpload,
                    ),
                  ],
                ),
              ),
              if (_errors.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  t.previewSimulation,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final err in _errors.take(20))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      [
                        if (err.row != null) 'L${err.row}',
                        if (err.sku != null) err.sku!,
                        if (err.code != null) err.code!,
                        if (err.message != null) err.message!,
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
