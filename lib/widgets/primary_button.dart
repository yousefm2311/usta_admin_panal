import 'dart:async';

import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final FutureOr<void> Function()? onPressed;
  final IconData? icon;
  final bool expand;
  final bool isLoading;
  final String? loadingLabel;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
    this.isLoading = false,
    this.loadingLabel,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _busy = false;

  Future<void> _handlePressed() async {
    if (_busy || widget.isLoading) return;
    final callback = widget.onPressed;
    if (callback == null) return;
    final result = callback();
    if (result is Future) {
      setState(() => _busy = true);
      try {
        await result;
      } finally {
        if (mounted) {
          setState(() => _busy = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.isLoading || _busy;
    final canPress = widget.onPressed != null;
    final label = busy ? (widget.loadingLabel ?? widget.label) : widget.label;

    final spinnerColor = Theme.of(context).colorScheme.onPrimary;
    final iconWidget = busy
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(spinnerColor),
            ),
          )
        : widget.icon != null
        ? Icon(widget.icon, color: spinnerColor)
        : null;

    final button = iconWidget != null
        ? ElevatedButton.icon(
            onPressed: canPress ? _handlePressed : null,
            icon: iconWidget,
            label: Text(label),
          )
        : ElevatedButton(
            onPressed: canPress ? _handlePressed : null,
            child: Text(label),
          );

    return SizedBox(
      width: widget.expand ? double.infinity : null,
      child: busy && canPress ? AbsorbPointer(child: button) : button,
    );
  }
}
