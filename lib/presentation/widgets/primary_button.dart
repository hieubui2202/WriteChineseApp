import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final ButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isSecondary = variant == ButtonVariant.secondary;
    final background = isSecondary ? const Color(0xFF1F2933) : const Color(0xFF00CFFF);
    final textColor = isSecondary ? const Color(0xFF00CFFF) : Colors.black;
    final borderColor = const Color(0xFF00CFFF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CFFF).withOpacity(isSecondary ? 0.1 : 0.4),
            blurRadius: isSecondary ? 12 : 24,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor.withOpacity(isSecondary ? 0.4 : 0.9), width: 1.6),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
