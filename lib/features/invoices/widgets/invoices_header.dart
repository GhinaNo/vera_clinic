import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InvoicesHeader extends StatelessWidget {
  final VoidCallback onAddInvoice;
  final VoidCallback onToggleArchiveView;
  final bool isArchiveMode;

  const InvoicesHeader({
    super.key,
    required this.onAddInvoice,
    required this.onToggleArchiveView,
    required this.isArchiveMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onAddInvoice,
              icon: const Icon(Icons.add, color: AppColors.offWhite),
              label: const Text('فاتورة جديدة', style: TextStyle(color: AppColors.offWhite)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onToggleArchiveView,
              icon: Icon(isArchiveMode ? Icons.list : Icons.archive,color: AppColors.offWhite,),
              label: Text(isArchiveMode ? 'عرض الفواتير' : 'عرض الأرشيف',style: TextStyle(color: AppColors.offWhite),),
              style: TextButton.styleFrom(backgroundColor: AppColors.purple),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.receipt_long, color: AppColors.purple, size: 30),
            const SizedBox(width: 10),
            Text(
              isArchiveMode ? 'الأرشيف' : 'قائمة الفواتير',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
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
