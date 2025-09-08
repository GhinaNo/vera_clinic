import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api.dart'; // استدعاء baseUrl

class NotificationsPage extends StatefulWidget {
  final String token;

  const NotificationsPage({super.key, required this.token});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);

    final url = Uri.parse("$baseUrl/web/notification");
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.token}",
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        notifications = body["data"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception("فشل في الحصول على الإشعارات");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.purple),
            onPressed: fetchNotifications,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("لا توجد إشعارات"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final data = notif["data"] ?? {};
                    final title = data["title"] ?? "بدون عنوان";
                    final message = data["message"] ?? "";
                    final service = data["service"] ?? "";
                    final date = data["date"] ?? "";
                    final status = data["status"] ?? "";
                    final createdAt = notif["created_at"] ?? "";

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: const Icon(Icons.notifications,
                              color: Colors.purple),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message),
                            if (service.isNotEmpty)
                              Text("الخدمة: $service",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            if (date.isNotEmpty)
                              Text("التاريخ: $date",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            if (status.isNotEmpty)
                              Text("الحالة: $status",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: status == "confirmed"
                                        ? Colors.green
                                        : Colors.orange,
                                  )),
                          ],
                        ),
                        trailing: Text(
                          createdAt.toString().substring(0, 10),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
