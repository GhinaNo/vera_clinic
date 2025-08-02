import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/invoices_cubit.dart';
import '../models/invoice_model.dart';
import 'invoice_details_page.dart';

class InvoiceListView extends StatefulWidget {
  final bool showArchived;

  const InvoiceListView({super.key, required this.showArchived});

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
        _buildSearchAndFilterBar(),
        const SizedBox(height: 6),
        Expanded(
          child: BlocBuilder<InvoicesCubit, List<Invoice>>(
            builder: (context, invoices) {
              final visibleInvoices = invoices
                  .where((i) =>
              i.isArchived == widget.showArchived &&
                  (searchQuery.isEmpty || i.customerName.contains(searchQuery)))
                  .toList()
                ..sort((a, b) {
                  final cmp = sortByAmount
                      ? a.totalAmount.compareTo(b.totalAmount)
                      : a.date.compareTo(b.date);
                  return ascending ? cmp : -cmp;
                });

              if (visibleInvoices.isEmpty) {
                return _buildEmptyState();
              }

              return AnimationLimiter(
                key: ValueKey('${visibleInvoices.length}_${widget.showArchived}'),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: visibleInvoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final invoice = visibleInvoices[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildInvoiceCard(invoice),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث باسم العميل',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => searchQuery = value.trim()),
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
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/No_data.gif', height: 250, width: 200),
        const SizedBox(height: 16),
        Text(
          widget.showArchived ? 'لا توجد فواتير مؤرشفة' : 'لا توجد فواتير حالياً',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(invoice),
            const SizedBox(height: 12),
            _buildAmounts(invoice),
            const SizedBox(height: 10),
            _buildCardActions(invoice),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Invoice invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(invoice.customerName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(_formatDate(invoice.date),
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAmounts(Invoice invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAmountInfo('الإجمالي', invoice.totalAmount),
        _buildAmountInfo('المدفوع', invoice.paidAmount),
        _buildAmountInfo(
          'المتبقي',
          invoice.remainingAmount,
          color: invoice.remainingAmount > 0 ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildCardActions(Invoice invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
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
        IconButton(
          icon: Icon(
            invoice.isArchived ? Icons.unarchive : Icons.archive_outlined,
            color: Colors.grey,
          ),
          tooltip: invoice.isArchived ? 'استرجاع' : 'أرشفة',
          onPressed: () => _handleArchiveAction(invoice),
        ),
      ],
    );
  }

  Future<void> _handleArchiveAction(Invoice invoice) async {
    final isArchiving = !invoice.isArchived;

    if (isArchiving && invoice.remainingAmount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن أرشفة فاتورة غير مدفوعة بالكامل')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد العملية'),
        content: Text(isArchiving
            ? 'هل تريد أرشفة هذه الفاتورة؟'
            : 'هل تريد استرجاع هذه الفاتورة من الأرشيف؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cubit = context.read<InvoicesCubit>();
      if (isArchiving) {
        cubit.archiveInvoice(invoice.id);
      } else {
        cubit.unarchiveInvoice(invoice.id);
      }
    }
  }

  Widget _buildAmountInfo(String label, double amount, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        const SizedBox(height: 4),
        Text('${amount.toStringAsFixed(0)} ل.س',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.purple,
            )),
      ],
    );
  }
}
