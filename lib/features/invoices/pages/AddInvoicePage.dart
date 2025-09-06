// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:uuid/uuid.dart';
// import 'package:vera_clinic/features/invoices/models/invoice_model.dart';
// import 'package:vera_clinic/features/services/cubit/ServicesCubit.dart';
// import 'package:vera_clinic/features/services/models/service.dart';
// import '../cubit_invoices/invoices_cubit.dart';
// import '../models/InvoiceItem.dart';
// import '../models/payment_model.dart';
//
// class AddInvoicePage extends StatefulWidget {
//   const AddInvoicePage({super.key});
//
//   @override
//   State<AddInvoicePage> createState() => _AddInvoicePageState();
// }
//
// class _AddInvoicePageState extends State<AddInvoicePage> with TickerProviderStateMixin {
//   final List<String> dummyCustomers = ['آية محمد', 'سارة الأحمد', ' نور خليل', ' هالة ديوب'];
//
//   String? selectedCustomer;
//   List<Service> selectedServices = [];
//   final TextEditingController paidAmountController = TextEditingController();
//   final TextEditingController customerSearchController = TextEditingController();
//   List<String> filteredCustomers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     filteredCustomers = List.from(dummyCustomers);
//     paidAmountController.text = '0';
//   }
//
//   @override
//   void dispose() {
//     paidAmountController.dispose();
//     customerSearchController.dispose();
//     super.dispose();
//   }
//
//   double get totalPrice => selectedServices.fold(0, (sum, item) => sum + item.price);
//   double get paidAmount => double.tryParse(paidAmountController.text) ?? 0;
//   double get remainingAmount => (totalPrice - paidAmount).clamp(0, double.infinity);
//
//   void _filterCustomers(String query) {
//     setState(() {
//       filteredCustomers = dummyCustomers.where((c) => c.contains(query.trim())).toList();
//     });
//   }
//
//   Future<void> _showServicePickerDialog(List<Service> services) async {
//     List<Service> filteredServices = List.from(services);
//     TextEditingController searchController = TextEditingController();
//
//     Service? picked = await showDialog<Service>(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             void filter(String query) {
//               setState(() {
//                 filteredServices = services.where((s) => s.name.contains(query.trim())).toList();
//               });
//             }
//
//             return Dialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: SizedBox(
//                 width: 350,
//                 height: 500,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('اختر خدمة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: searchController,
//                         onChanged: filter,
//                         decoration: InputDecoration(
//                           hintText: 'ابحث عن خدمة...',
//                           prefixIcon: const Icon(Icons.search),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Expanded(
//                         child: filteredServices.isEmpty
//                             ? const Center(child: Text('لا توجد خدمات مطابقة'))
//                             : ListView.builder(
//                           itemCount: filteredServices.length,
//                           itemBuilder: (context, index) {
//                             final s = filteredServices[index];
//                             return Card(
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                               margin: const EdgeInsets.symmetric(vertical: 6),
//                               child: ListTile(
//                                 contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                                 title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
//                                 trailing: Text('${s.price.toStringAsFixed(0)} ل.س', style: const TextStyle(color: Colors.teal)),
//                                 onTap: () => Navigator.of(context).pop(s),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('إلغاء'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//
//     if (picked != null && !selectedServices.contains(picked)) {
//       setState(() {
//         selectedServices.add(picked);
//       });
//     }
//   }
//
//   void _onPaidAmountChanged(String value) {
//     double val = double.tryParse(value) ?? 0;
//     if (val > totalPrice) {
//       paidAmountController.text = totalPrice.toStringAsFixed(0);
//     }
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final services = context.watch<ServicesCubit>().state;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إنشاء فاتورة جديدة'),
//         centerTitle: true,
//       ),
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('معلومات الزبون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: customerSearchController,
//                 decoration: InputDecoration(
//                   labelText: 'ابحث عن زبون',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   suffixIcon: const Icon(Icons.search),
//                 ),
//                 onChanged: _filterCustomers,
//               ),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: 'اختر الزبون',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 value: selectedCustomer,
//                 items: filteredCustomers.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
//                 onChanged: (value) => setState(() => selectedCustomer = value),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('الخدمات المختارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.add),
//                     label: const Text('أضف خدمة'),
//                     onPressed: () => _showServicePickerDialog(services as List<Service>),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               selectedServices.isEmpty
//                   ? Column(
//                 children: [
//
//                   const SizedBox(height: 12),
//                   const Text('لم يتم اختيار خدمات بعد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//                 ],
//               )
//                   : AnimationLimiter(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: selectedServices.length,
//                   itemBuilder: (context, index) {
//                     final s = selectedServices[index];
//                     return AnimationConfiguration.staggeredList(
//                       position: index,
//                       duration: const Duration(milliseconds: 400),
//                       child: SlideAnimation(
//                         horizontalOffset: 50.0,
//                         child: FadeInAnimation(
//                           child: Card(
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                             elevation: 3,
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                               leading: const Icon(Icons.check_circle_outline, color: Colors.teal),
//                               title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                               subtitle: Text('${s.price.toStringAsFixed(0)} ل.س', style: const TextStyle(fontSize: 14, color: Colors.grey)),
//                               trailing: IconButton(
//                                 icon: const Icon(Icons.delete_forever_outlined, color: Colors.red),
//                                 onPressed: () {
//                                   setState(() {
//                                     selectedServices.removeAt(index);
//                                     if (paidAmount > totalPrice) {
//                                       paidAmountController.text = totalPrice.toStringAsFixed(0);
//                                     }
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text('الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: paidAmountController,
//                 keyboardType: const TextInputType.numberWithOptions(decimal: false),
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 decoration: InputDecoration(
//                   labelText: 'المبلغ المدفوع',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   suffixText: 'ل.س',
//                   errorText: (paidAmount > totalPrice) ? 'المبلغ أكبر من إجمالي الفاتورة' : null,
//                 ),
//                 onChanged: _onPaidAmountChanged,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('المبلغ المتبقي:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                   Text('${remainingAmount.toStringAsFixed(0)} ل.س',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: remainingAmount > 0 ? Colors.red : Colors.green,
//                       )),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.save),
//                   label: const Text('حفظ الفاتورة'),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(50),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   onPressed: () {
//                     if (selectedCustomer == null || selectedServices.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار زبون وخدمة على الأقل')));
//                       return;
//                     }
//
//                     final paid = double.tryParse(paidAmountController.text) ?? 0;
//
//                     final invoice = Invoice(
//                       id : const Uuid().v4(),
//                       customerName: selectedCustomer!,
//                       items: selectedServices.map((s) => InvoiceItem(serviceName: s.name, price: s.price)).toList(),
//                       totalAmount: totalPrice,
//                       payments: [Payment(amount: paid, date: DateTime.now())],
//                       date: DateTime.now(),
//                       createdBy: 'المستخدم الحالي',
//                     );
//
//                     context.read<InvoicesCubit>().addInvoice(invoice);
//
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✔ تم حفظ الفاتورة')));
//
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
