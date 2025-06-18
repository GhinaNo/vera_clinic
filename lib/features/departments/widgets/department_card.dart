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
    return GestureDetector(
      onTap: () => _showDetailsDialog(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        shadowColor: AppColors.purple.withOpacity(0.4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          constraints: const BoxConstraints(maxHeight: 150),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.purple.withOpacity(0.95),
                AppColors.purple.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                department.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      department.supervisor,
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.meeting_room_outlined, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      department.location,
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: Text(
                  department.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
        content: SingleChildScrollView(
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
                        constraints: BoxConstraints(
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
