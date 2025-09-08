import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api.dart';
class BookingPage extends StatefulWidget {
  final String token;

  const BookingPage({super.key, required this.token});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<dynamic> bookings = [];
  List<dynamic> allBookings = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/web/get-bookings"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allBookings = data["data"];
          bookings = allBookings;
          isLoading = false;
        });
      } else {
        throw Exception("فشل في الحصول على البيانات: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterBookings(String query) {
    query = query.toLowerCase();
    setState(() {
      bookings = allBookings.where((booking) {
        final name = (booking["user"]["name"] ?? "").toString().toLowerCase();
        final email = (booking["user"]["email"] ?? "").toString().toLowerCase();
        final userId = (booking["user"]["id"] ?? "").toString();
        return name.contains(query) || email.contains(query) || userId.contains(query);
      }).toList();
    });
  }

  Future<void> updateBookingStatus(int bookingId, String action) async {
    String url = "";
    switch (action) {
      case "confirm":
        url = "$baseUrl/web/booking-approve/$bookingId";
        break;
      case "reject":
        url = "$baseUrl/web/booking-reject/$bookingId";
        break;
      case "cancel":
        url = "$baseUrl/web/canceled-booking/$bookingId";
        break;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = bookings.indexWhere((b) => b["id"] == bookingId);
          if (index != -1) {
            bookings[index]["status"] = action == "confirm"
                ? "confirmed"
                : action == "reject"
                    ? "rejected"
                    : "cancelled";
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث الحجز بنجاح")),
        );
      } else {
        throw Exception("فشل التحديث ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ أثناء التحديث")),
      );
    }
  }

  Future<void> createInvoice(int bookingId) async {
    final url = "$baseUrl/web/invoice/$bookingId";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إنشاء الفاتورة بنجاح")),
        );
      } else {
        throw Exception("فشل إنشاء الفاتورة: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء إنشاء الفاتورة أو أن الفاتورة موجودة")),
      );
    }
  }

  Future<void> editBooking(int bookingId, int serviceId, DateTime newDate) async {
    try {
      final url = Uri.parse("$baseUrl/web/update-booking/$bookingId");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: {
          "service_id": serviceId.toString(),
          "booking_date": newDate.toIso8601String(),
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse["status"] == 1) {
        final updatedBooking = jsonResponse["data"]["booking"];
        setState(() {
          final index = bookings.indexWhere((b) => b["id"] == bookingId);
          if (index != -1) {
            bookings[index] = updatedBooking;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تعديل الموعد بنجاح")),
        );
        fetchBookings();
      } else {
        final message = jsonResponse["message"] ?? "حدث خطأ";
        final availableSlots = jsonResponse["available_slots"] ?? [];

        if (message.contains("time is not available") && availableSlots.isNotEmpty) {
          showEditDialog(bookingId, serviceId, newDate.toIso8601String(), availableSlots);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (e) {
      debugPrint("خطأ $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء تعديل الموعد")),
      );
    }
  }

  void showEditDialog(int bookingId, int serviceId, String oldDate, List<dynamic> availableSlots) {
    DateTime selectedDate = DateTime.tryParse(oldDate) ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("تعديل الموعد"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${selectedDate.toLocal()}".split(".")[0]),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (newDate != null) {
                      final newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (newTime != null) {
                        setState(() {
                          selectedDate = DateTime(
                            newDate.year,
                            newDate.month,
                            newDate.day,
                            newTime.hour,
                            newTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: const Text("اختيار التاريخ والوقت"),
                ),
                if (availableSlots.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text("الأوقات المتاحة:"),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: availableSlots.map<Widget>((slot) {
                          final slotText = "${slot["start"]} - ${slot["end"]}";
                          return ListTile(
                            title: Text(slotText),
                            onTap: () {
                              final timeParts = slot["start"].split(":");
                              final newDateTime = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                int.parse(timeParts[0]),
                                int.parse(timeParts[1]),
                              );
                              Navigator.pop(context);
                              editBooking(bookingId, serviceId, newDateTime);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  editBooking(bookingId, serviceId, selectedDate);
                },
                child: const Text("تأكيد"),
              ),
            ],
          );
        });
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "confirmed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      case "rejected":
        return Colors.redAccent;
      case "completed":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("إدارة الحجوزات"),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: TextField(
                controller: searchController,
                onChanged: filterBookings,
                decoration: InputDecoration(
                  hintText: "ابحث بالاسم أو البريد أو ID",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            searchController.clear();
                            filterBookings("");
                          },
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchBookings,
            tooltip: "تحديث",
          ),
        ],
        toolbarHeight: 100,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text("لا يوجد حجوزات"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final bookingId = booking["id"];
                      final userName = booking["user"]["name"] ?? "بدون اسم";
                      final userEmail = booking["user"]["email"] ?? "بدون ايميل";
                      final userId = booking["user"]["id"] ?? "";
                      final service = booking["service"];
                      final serviceId = service?["id"] ?? 0;
                      final serviceName = service?["name"] ?? "خدمة غير معروفة";
                      final status = booking["status"] ?? "unknown";
                      final date = booking["booking_date"] ?? "";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.purple.shade100,
                                    child: Text(
                                      userName[0],
                                      style: const TextStyle(color: Colors.purple),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                userEmail,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "ID: $userId",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          status,
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text("الخدمة: $serviceName",
                                  style: const TextStyle(color: Colors.black54, fontSize: 14)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(date, style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => updateBookingStatus(bookingId, "confirm"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                    ),
                                    child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () => updateBookingStatus(bookingId, "reject"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text("Reject"),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => updateBookingStatus(bookingId, "cancel"),
                                    child: const Text("Cancel"),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => showEditDialog(
                                      bookingId,
                                      serviceId,
                                      booking["booking_date"],
                                      [],
                                    ),
                                    child: const Text("تعديل 📅"),
                                  ),
                                  const Spacer(),
                                  OutlinedButton(
                                    onPressed: () => createInvoice(bookingId),
                                    child: const Text("Add Invoice"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
