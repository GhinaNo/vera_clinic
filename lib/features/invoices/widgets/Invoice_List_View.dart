import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/invoices_cubit.dart';
import '../models/invoice_model.dart';
import 'invoice_details_page.dart';

class InvoiceListView extends StatefulWidget {
  const InvoiceListView({super.key});

  @override
  State<InvoiceListView> createState() => _InvoiceListViewState();
}

class _InvoiceListViewState extends State<InvoiceListView> {
  String searchQuery = '';
  bool sortByAmount = true;
  bool ascending = true;

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم العميل',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.tune, color: AppColors.purple),
                onSelected: (value) {
                  setState(() {
                    if (value == 'amount' || value == 'date') {
                      sortByAmount = (value == 'amount');
                    } else if (value == 'asc' || value == 'desc') {
                      ascending = (value == 'asc');
                    }
                  });
                },
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    checked: sortByAmount,
                    value: 'amount',
                    child: const Text('حسب المبلغ'),
                  ),
                  CheckedPopupMenuItem(
                    checked: !sortByAmount,
                    value: 'date',
                    child: const Text('حسب التاريخ'),
                  ),
                  const PopupMenuDivider(),
                  CheckedPopupMenuItem(
                    checked: ascending,
                    value: 'asc',
                    child: const Text('تصاعدي'),
                  ),
                  CheckedPopupMenuItem(
                    checked: !ascending,
                    value: 'desc',
                    child: const Text('تنازلي'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<InvoicesCubit, List<Invoice>>(
            builder: (context, invoices) {
              final filtered = invoices
                  .where((invoice) =>
              invoice.customerName.contains(searchQuery) || searchQuery.isEmpty)
                  .toList()
                ..sort((a, b) {
                  final cmp = sortByAmount
                      ? a.totalAmount.compareTo(b.totalAmount)
                      : a.date.compareTo(b.date);
                  return ascending ? cmp : -cmp;
                });

              if (filtered.isEmpty) {
                return const Center(child: Text('لا توجد فواتير بعد.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final invoice = filtered[index];

                  return TweenAnimationBuilder<double>(
                    key: ValueKey(invoice.id),
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(begin: 0.95, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  invoice.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  _formatDate(invoice.date),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildAmountInfo('الإجمالي', invoice.totalAmount),
                                _buildAmountInfo('المدفوع', invoice.paidAmount),
                                _buildAmountInfo(
                                  'المتبقي',
                                  (invoice.totalAmount - invoice.paidAmount),
                                  color: (invoice.totalAmount - invoice.paidAmount) > 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.info_outline, color: AppColors.purple),
                                tooltip: 'تفاصيل',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<InvoicesCubit>(),
                                      child: InvoiceDetailsPage(invoice: invoice),
                                    ),
                                  );

                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo(String label, double amount, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)} ل.س',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.purple,
          ),
        ),
      ],
    );
  }
}
