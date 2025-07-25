import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InvoicesHeader extends StatelessWidget {
  final VoidCallback onAddInvoice;

  const InvoicesHeader({super.key, required this.onAddInvoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onAddInvoice,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('فاتورة جديدة', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.receipt_long, color: AppColors.purple, size: 30),
            const SizedBox(width: 10),
            Text(
              'قائمة الفواتير',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: 120,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
