import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? ElevatedButton.icon(
          
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
            label: Text(label),
          )
        : ElevatedButton(
            onPressed: onPressed,
            child: Text(label),
          );
    return SizedBox(
      width: expand ? double.infinity : null,
      child: button,
    );
  }
}
