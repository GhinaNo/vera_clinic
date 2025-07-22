import 'package:flutter/material.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';
import '../models/department.dart';

class DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DepartmentCard({
    super.key,
    required this.department,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showDetailsDialog(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: AppColors.purple.withOpacity(0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.purple.withOpacity(0.95),
                AppColors.purple.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  department.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.white70, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        department.supervisor,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined, color: Colors.white70, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        department.location,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 100,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      department.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.offWhite,
        title: Row(
          children: [
            const Icon(Icons.apartment, color: AppColors.purple, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                department.name,
                style: const TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 350,
            minWidth: 280,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoTile('الطبيب المشرف', department.supervisor, Icons.person_outline),
                _buildInfoTile('رقم الجناح', department.location, Icons.meeting_room_outlined),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 24, color: AppColors.purple.withOpacity(0.9)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 150,
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              'حول هذا القسم: ${department.description}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.purple,
                                fontSize: 16,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: AppColors.purple, fontSize: 16)),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.microtask(onEdit);
            },
            icon: const Icon(Icons.edit, color: AppColors.purple, size: 26),
            tooltip: 'تعديل',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.microtask(onDelete);
            },
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 26),
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.purple.withOpacity(0.9)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
