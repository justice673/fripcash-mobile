import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final int length;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode()..addListener(_onFocusChange));
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.removeListener(_onFocusChange);
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _notifyChange() {
    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _fillFromPaste(value);
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
    _notifyChange();
  }

  void _fillFromPaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    if (digits.length >= widget.length) {
      _focusNodes[widget.length - 1].requestFocus();
    } else if (digits.isNotEmpty) {
      _focusNodes[digits.length.clamp(0, widget.length - 1)].requestFocus();
    }
    setState(() {});
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 8.0;
        final available = constraints.maxWidth;
        final boxWidth = ((available - gap * (widget.length - 1)) / widget.length)
            .clamp(40.0, 52.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              _OtpBox(
                width: boxWidth,
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                hasValue: _controllers[i].text.isNotEmpty,
                onChanged: (value) => _onChanged(i, value),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.width,
    required this.controller,
    required this.focusNode,
    required this.hasValue,
    required this.onChanged,
  });

  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    final borderColor = focused
        ? AppColors.primary
        : hasValue
            ? AppColors.primary.withValues(alpha: 0.45)
            : Colors.grey.shade300;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: 56,
      decoration: BoxDecoration(
        color: focused
            ? AppColors.primary.withValues(alpha: 0.06)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: focused ? 1.8 : 1.2,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTypography.style(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        cursorColor: AppColors.primary,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
