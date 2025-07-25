import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/invoices_cubit.dart';
import '../models/invoice_model.dart';
import '../models/payment.dart';

class InvoiceDetailsPage extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailsPage({Key? key, required this.invoice}) : super(key: key);

  @override
  State<InvoiceDetailsPage> createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  late Invoice invoice;

  @override
  void initState() {
    super.initState();
    invoice = widget.invoice;
  }

  void _addPayment() async {
    final result = await showDialog<Payment>(
      context: context,
      builder: (context) => AddPaymentDialog(maxAmount: invoice.remainingAmount),
    );

    if (result != null) {
      setState(() {
        invoice.payments.add(result);
      });

      context.read<InvoicesCubit>().updateInvoice(invoice);
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: valueColor ?? Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(int index) {
    final item = invoice.items[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              item.serviceName,
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${item.price.toStringAsFixed(2)} ل.س',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${invoice.date.year}/${invoice.date.month.toString().padLeft(2, '0')}/${invoice.date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفاتورة'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoRow('العميل', invoice.customerName),
            _buildInfoRow('التاريخ', dateStr),

            const SizedBox(height: 20),

            const Text(
              'الخدمات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: invoice.items.length,
                itemBuilder: (context, index) => _buildServiceItem(index),
              ),
            ),

            const Divider(height: 30, thickness: 1.2),

            _buildInfoRow('إجمالي الفاتورة', '${invoice.totalAmount.toStringAsFixed(2)} ل.س'),
            _buildInfoRow('المدفوع', '${invoice.paidAmount.toStringAsFixed(2)} ل.س'),
            _buildInfoRow(
              'المتبقي',
              '${invoice.remainingAmount.toStringAsFixed(2)} ل.س',
              valueColor: invoice.remainingAmount > 0 ? Colors.red : Colors.green,
            ),

            const SizedBox(height: 20),
            if (invoice.payments.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'سجل الدفعات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoice.payments.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final p = invoice.payments[index];
                  final date = '${p.date.year}/${p.date.month.toString().padLeft(2, '0')}/${p.date.day.toString().padLeft(2, '0')}';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.payments, color: Colors.teal),
                    title: Text('${p.amount.toStringAsFixed(2)} ل.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('بتاريخ: $date'),
                  );
                },
              ),
            ],


            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('إضافة دفعة'),
              onPressed: invoice.remainingAmount > 0 ? _addPayment : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPaymentDialog extends StatefulWidget {
  final double maxAmount;

  const AddPaymentDialog({Key? key, required this.maxAmount}) : super(key: key);

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final payment = Payment(amount: amount, date: DateTime.now());
      Navigator.of(context).pop(payment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة دفعة'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'المبلغ (أقل من ${widget.maxAmount.toStringAsFixed(2)})',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال مبلغ';
            }
            final val = double.tryParse(value);
            if (val == null || val <= 0) {
              return 'المبلغ غير صالح';
            }
            if (val > widget.maxAmount) {
              return 'المبلغ أكبر من المتبقي';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
        ElevatedButton(onPressed: _submit, child: const Text('حفظ')),
      ],
    );
  }
}
