// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:vera_clinic/features/invoices/pages/AddInvoicePage.dart';
//
// import 'booking_cubit.dart';
// import 'booking_state.dart';
// import 'booking_model.dart';
//
// class Appointment {
//   String customer;
//   String service;
//   String time;
//   String status; // pending, accepted, rejected, cancelled
//   String? rejectionReason;
//   bool archived;
//   String? invoiceId; // جديد: لتخزين رقم الفاتورة إذا تم إنشاؤها
//
//   Appointment({
//     required this.customer,
//     required this.service,
//     required this.time,
//     this.status = 'pending',
//     this.rejectionReason,
//     this.archived = false,
//     this.invoiceId,
//   });
// }
//
// class AppointmentHomePage extends StatefulWidget {
//   final String token;
//   const AppointmentHomePage({super.key, required this.token});
//
//   @override
//   State<AppointmentHomePage> createState() => _AppointmentHomePageState();
// }
//
// class _AppointmentHomePageState extends State<AppointmentHomePage> {
//   final List<Appointment> _appointments = [];
//   final List<Appointment> _appRequests = [];
//   String currentMode = "appointments"; // appointments, archive, requests
//
//   List<Map<String, dynamic>> _services = [];
//   List<Map<String, dynamic>> _availableSlots = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchServices();
//   }
//
//   Future<void> _fetchServices() async {
//     try {
//       final response = await http.get(
//         Uri.parse("http://127.0.0.1:8000/web/services"),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer ${widget.token}",
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data["status"] == 1) {
//           setState(() {
//             _services = List<Map<String, dynamic>>.from(data["data"]);
//           });
//         } else {
//           print("Error loading services: ${data["message"]}");
//         }
//       } else {
//         print("Failed to load services: ${response.body}");
//       }
//     } catch (e) {
//       print("Error fetching services: $e");
//     }
//   }
//
//   Future<void> _fetchAvailableSlots(String serviceId, String date) async {
//     try {
//       final response = await http.post(
//         Uri.parse("http://127.0.0.1:8000/web/available"),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer ${widget.token}",
//         },
//         body: {
//           "service_id": serviceId,
//           "date": date,
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data["status"] == 1 && data["data"]["status"] == 1) {
//           setState(() {
//             _availableSlots =
//             List<Map<String, dynamic>>.from(data["data"]["available_slots"]);
//           });
//         } else {
//           print("Error loading slots: ${data["data"]["message"]}");
//         }
//       } else {
//         print("Failed to load slots: ${response.body}");
//       }
//     } catch (e) {
//       print("Error fetching slots: $e");
//     }
//   }
//
//   void _addAppointmentDialog({bool isRequest = false}) {
//     final TextEditingController nameController = TextEditingController();
//     Map<String, dynamic>? selectedService;
//     Map<String, dynamic>? selectedSlot;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return BlocProvider(
//           create: (_) => BookingCubit(),
//           child: BlocConsumer<BookingCubit, BookingState>(
//             listener: (context, state) {
//               if (state is BookingSuccess) {
//                 setState(() {
//                   final booking = state.booking;
//                   final appt = Appointment(
//                     customer: booking.userId,
//                     service: booking.service.name,
//                     time: booking.bookingDate,
//                     status: booking.status,
//                   );
//                   if (isRequest) {
//                     _appRequests.add(appt);
//                   } else {
//                     _appointments.add(appt);
//                   }
//
//                   _availableSlots.removeWhere(
//                           (slot) => booking.bookingDate.contains(slot["start"]));
//                 });
//                 Navigator.pop(context);
//               } else if (state is BookingFailure) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(state.message)),
//                 );
//               }
//             },
//             builder: (context, state) {
//               return AlertDialog(
//                 title: Text(isRequest ? 'إضافة طلب تطبيق' : 'إضافة حجز جديد'),
//                 content: StatefulBuilder(
//                   builder: (context, setState) {
//                     return SingleChildScrollView(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           TextField(
//                             controller: nameController,
//                             decoration:
//                             const InputDecoration(labelText: 'اسم الزبون'),
//                           ),
//                           const SizedBox(height: 8),
//                           DropdownButton<Map<String, dynamic>>(
//                             hint: const Text('اختر الخدمة'),
//                             value: selectedService,
//                             items: _services
//                                 .map(
//                                   (s) => DropdownMenuItem(
//                                 value: s,
//                                 child: Text(s["name"]),
//                               ),
//                             )
//                                 .toList(),
//                             onChanged: (val) async {
//                               setState(() {
//                                 selectedService = val;
//                                 selectedSlot = null;
//                               });
//                               if (selectedService != null) {
//                                 final today = DateTime.now()
//                                     .toString()
//                                     .split(" ")[0];
//                                 await _fetchAvailableSlots(
//                                     selectedService!["id"].toString(), today);
//                                 setState(() {});
//                               }
//                             },
//                           ),
//                           const SizedBox(height: 8),
//                           if (_availableSlots.isNotEmpty)
//                             DropdownButton<Map<String, dynamic>>(
//                               hint: const Text('اختر الوقت'),
//                               value: selectedSlot,
//                               items: _availableSlots
//                                   .map(
//                                     (s) => DropdownMenuItem(
//                                   value: s,
//                                   child: Text(
//                                       "${s["start"]} - ${s["end"]}"),
//                                 ),
//                               )
//                                   .toList(),
//                               onChanged: (val) {
//                                 setState(() {
//                                   selectedSlot = val;
//                                 });
//                               },
//                             ),
//                           if (state is BookingLoading) ...[
//                             const Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: CircularProgressIndicator(),
//                             ),
//                           ]
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('إلغاء'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (nameController.text.isNotEmpty &&
//                           selectedService != null &&
//                           selectedSlot != null) {
//                         final today =
//                         DateTime.now().toString().split(" ")[0];
//                         context.read<BookingCubit>().storeBooking(
//                           userId: nameController.text,
//                           serviceId: selectedService!["id"].toString(),
//                           bookingDate: "$today ${selectedSlot!["start"]}",
//                         );
//                       }
//                     },
//                     child: const Text('إضافة'),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   void _editAppointmentDialog(Appointment appt) {
//     Map<String, dynamic>? selectedService =
//     _services.firstWhere((s) => s["name"] == appt.service,
//         orElse: () => _services.first);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('تعديل'),
//           content: StatefulBuilder(
//             builder: (context, setState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     DropdownButton<Map<String, dynamic>>(
//                       value: selectedService,
//                       items: _services
//                           .map((s) => DropdownMenuItem(
//                         value: s,
//                         child: Text(s["name"]),
//                       ))
//                           .toList(),
//                       onChanged: (val) {
//                         setState(() {
//                           selectedService = val!;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('إلغاء'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   appt.service = selectedService!["name"];
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('حفظ'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _rejectAppointment(Appointment appt) {
//     final TextEditingController reasonController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('سبب الرفض'),
//         content: TextField(
//           controller: reasonController,
//           decoration: const InputDecoration(labelText: 'أدخل السبب'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 appt.status = 'rejected';
//                 appt.rejectionReason = reasonController.text;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('رفض'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _toggleArchive(Appointment appt) {
//     setState(() => appt.archived = !appt.archived);
//   }
//
//   Color _getCardColor(Appointment appt) {
//     if (appt.status == 'accepted') return Colors.green.shade100;
//     if (appt.status == 'rejected') return Colors.red.shade100;
//     return const Color.fromARGB(255, 239, 209, 252);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Appointment> visibleAppointments;
//     if (currentMode == "appointments") {
//       visibleAppointments = _appointments.where((a) => !a.archived).toList();
//     } else if (currentMode == "archive") {
//       visibleAppointments =
//           [..._appointments, ..._appRequests].where((a) => a.archived).toList();
//     } else {
//       visibleAppointments = _appRequests.where((a) => !a.archived).toList();
//     }
//
//     String title = currentMode == "appointments"
//         ? "قائمة الحجوزات"
//         : currentMode == "archive"
//         ? "الأرشيف"
//         : "طلبات التطبيق";
//
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 if (currentMode == "appointments") ...[
//                   ElevatedButton.icon(
//                     onPressed: () => _addAppointmentDialog(
//                         isRequest: currentMode == "requests"),
//                     icon: const Icon(Icons.add),
//                     label: Text(
//                         currentMode == "requests" ? 'إضافة طلب' : 'إضافة حجز'),
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     setState(() => currentMode = "appointments");
//                   },
//                   icon: const Icon(Icons.list),
//                   label: const Text('قائمة الحجوزات'),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     setState(() => currentMode = "archive");
//                   },
//                   icon: const Icon(Icons.archive),
//                   label: const Text('عرض الأرشيف'),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     setState(() => currentMode = "requests");
//                   },
//                   icon: const Icon(Icons.app_registration),
//                   label: const Text('طلبات التطبيق'),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
//             child: Row(
//               children: [
//                 Icon(Icons.receipt_long, color: Colors.purple, size: 30),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.purple,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: visibleAppointments.isEmpty
//                 ? Center(
//               child: Text(
//                 'لا يوجد بيانات',
//                 style: TextStyle(fontSize: 24, color: Colors.grey),
//               ),
//             )
//                 : ListView.builder(
//               itemCount: visibleAppointments.length,
//               itemBuilder: (context, index) {
//                 final appt = visibleAppointments[index];
//                 return Card(
//                   color: _getCardColor(appt),
//                   margin: const EdgeInsets.all(8),
//                   child: ListTile(
//                     title: Text('${appt.customer} - ${appt.service}'),
//                     subtitle: Text('الوقت: ${appt.time}\nالحالة: ${appt.status}' +
//                         (appt.rejectionReason != null
//                             ? "\nسبب الرفض: ${appt.rejectionReason}"
//                             : "")),
//                     isThreeLine: true,
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         if (currentMode != "archive") ...[
//                           IconButton(
//                             icon: const Icon(Icons.edit,
//                                 color: Colors.purple),
//                             onPressed: () =>
//                                 _editAppointmentDialog(appt),
//                           ),
//                         ],
//                         if (currentMode == "appointments") ...[
//                           IconButton(
//                             icon: const Icon(Icons.archive,
//                                 color: Colors.grey),
//                             onPressed: () => _toggleArchive(appt),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.cancel,
//                                 color: Colors.red),
//                             onPressed: () {
//                               setState(
//                                       () => appt.status = "cancelled");
//                             },
//                           ),
//                         ],
//                         if (currentMode == "requests") ...[
//                           IconButton(
//                             icon: const Icon(Icons.check,
//                                 color: Colors.green),
//                             onPressed: () {
//                               setState(() => appt.status = 'accepted');
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close,
//                                 color: Colors.red),
//                             onPressed: () => _rejectAppointment(appt),
//                           ),
//                           IconButton(
//                             icon: Icon(appt.archived
//                                 ? Icons.list
//                                 : Icons.archive),
//                             onPressed: () => _toggleArchive(appt),
//                           ),
//                         ],
//                         // زر إنشاء الفاتورة
//                         if (appt.status == 'accepted' && appt.invoiceId == null)
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => AddInvoicePage(
//                                     bookingId: appt.customer, // لاحقاً نربط id الصحيح
//                                   ),
//                                 ),
//                               ).then((createdInvoiceId) {
//                                 if (createdInvoiceId != null) {
//                                   setState(() => appt.invoiceId = createdInvoiceId);
//                                 }
//                               });
//                             },
//                             child: const Text('إنشاء فاتورة'),
//                           ),
//                         if (appt.invoiceId != null)
//                           ElevatedButton(
//                             onPressed: () {
//                               // فتح صفحة عرض الفاتورة
//                             },
//                             child: const Text('عرض الفاتورة'),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
