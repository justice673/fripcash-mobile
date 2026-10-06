import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class VacationModeScreen extends StatefulWidget {
  const VacationModeScreen({super.key});

  @override
  State<VacationModeScreen> createState() => _VacationModeScreenState();
}

class _VacationModeScreenState extends State<VacationModeScreen> {
  DateTime? _start;
  DateTime? _end;
  bool _enabled = false;
  bool _hideListings = true;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final v = await ListingsApi.instance.fetchVacation();
      if (!mounted) return;
      setState(() {
        _enabled = v.enabled;
        _start = v.startsAt;
        _end = v.endsAt;
        _hideListings = v.hideListings;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_start ?? DateTime.now())
        : (_end ?? DateTime.now().add(const Duration(days: 7)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      }
    });
  }

  String _formatDate(DateTime? date, String notSetLabel) {
    if (date == null) return notSetLabel;
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final saved = await ListingsApi.instance.putVacation(
        enabled: _enabled,
        startsAt: _start,
        endsAt: _end,
        hideListings: _hideListings,
      );
      if (!mounted) return;
      setState(() {
        _enabled = saved.enabled;
        _start = saved.startsAt;
        _end = saved.endsAt;
        _hideListings = saved.hideListings;
        _saving = false;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.vacationModeUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.vacationMode,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_loadError!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton(onPressed: _load, child: Text(t.retryAction)),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.vacationModeDescription,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          t.vacationMode,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        value: _enabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _enabled = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          t.hideListingsOnVacation,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        value: _hideListings,
                        activeThumbColor: AppColors.primary,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _hideListings = value),
                      ),
                      const SizedBox(height: 16),
                      _DateRow(
                        label: t.startDate,
                        value: _formatDate(_start, t.notSet),
                        onTap:
                            _saving ? () {} : () => _pickDate(isStart: true),
                      ),
                      const SizedBox(height: 10),
                      _DateRow(
                        label: t.endDate,
                        value: _formatDate(_end, t.notSet),
                        onTap:
                            _saving ? () {} : () => _pickDate(isStart: false),
                      ),
                      const Spacer(),
                      PillPrimaryButton(
                        label: _saving ? '…' : t.save,
                        onPressed: _saving ? null : _save,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(value),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
