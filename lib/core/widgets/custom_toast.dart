import 'package:flutter/material.dart';

import 'animated_toast.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final bool success;

  const CustomToast({
    Key? key,
    required this.message,
    this.success = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: success ? Colors.green : Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}


void showCustomToast(BuildContext context, String message, {bool success = false}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final overlayEntry = OverlayEntry(
    builder: (context) => AnimatedToast(message: message, success: success),
  );

  overlay.insert(overlayEntry);
}

