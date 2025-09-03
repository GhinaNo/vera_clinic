import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../cubit_client/user_cubit.dart';
import '../model/model_user.dart';

class ClientPage extends StatelessWidget {
  final ClientCubit cubit;
  const ClientPage({super.key, required this.cubit});

  void _showClientDetails(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(client.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),
              DetailRow(icon: Icons.email, label: "البريد", value: client.email),
              DetailRow(icon: Icons.verified_user, label: "الحالة", value: client.isActive ? "مفعل" : "غير مفعل"),
              DetailRow(icon: Icons.admin_panel_settings, label: "الدور", value: client.role ?? "-"),
              DetailRow(icon: Icons.calendar_today, label: "تاريخ الإنشاء", value: client.createdAt ?? "-"),
              DetailRow(icon: Icons.update, label: "آخر تحديث", value: client.updatedAt ?? "-"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("إغلاق",style: TextStyle(color: AppColors.offWhite),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddClientDialog(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddClientDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("إضافة", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "ابحث عن عميل...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (val) {
                      if (val.isEmpty) cubit.fetchClients();
                      else cubit.searchClient(val);
                    },
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ClientCubit, ClientState>(
              bloc: cubit,
              builder: (context, state) {
                if (state is ClientLoading) {
                  return Center(child: Text(state.message));
                }
                if (state is ClientError) {
                  return Center(child: Text(state.message));
                }
                if (state is ClientLoaded) {
                  final clients = state.clients;
                  if (clients.isEmpty) return const Center(child: Text('لا يوجد عملاء'));
                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (_, i) {
                      final c = clients[i];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.email),
                              const SizedBox(height: 4),
                              Text("الحالة: ${c.isActive ? "مفعل" : "غير مفعل"}"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              c.isActive ? Icons.check_circle : Icons.cancel,
                              color: c.isActive ? Colors.green : Colors.red,
                              size: 28,
                            ),
                            onPressed: () async {
                              try {
                                await cubit.toggleStatus(c.id);
                                showCustomToast(context, 'تم تبديل حالة العميل', success: true);
                              } catch (e) {
                                showCustomToast(context, e.toString(), success: false);
                              }
                            },
                          ),
                          onTap: () => _showClientDetails(context, c),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class AddClientDialog extends StatefulWidget {
  final ClientCubit cubit;
  const AddClientDialog({super.key, required this.cubit});

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', password = '', confirmPassword = '';

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await widget.cubit.addClient(
        Client(id: 0, name: name, email: email, isActive: true),
        password,
        confirmPassword,
      );

      await widget.cubit.fetchClients(); // تحديث القائمة من السيرفر

      showCustomToast(context, 'تم إضافة العميل بنجاح', success: true);
      Navigator.pop(context);
    } catch (e) {
      showCustomToast(context, 'فشل إضافة العميل: $e', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('إضافة عميل', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person)),
                onChanged: (v) => name = v,
                validator: (v) => v!.isEmpty ? 'الرجاء إدخال الاسم' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email)),
                onChanged: (v) => email = v,
                validator: (v) => v!.isEmpty ? 'الرجاء إدخال البريد' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) => v!.length < 6 ? 'كلمة المرور 6 محارف على الأقل' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
                onChanged: (v) => confirmPassword = v,
                validator: (v) => v != password ? 'تأكيد كلمة المرور لا يتطابق' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(onPressed: _submit, child:  Text('إضافة',style: TextStyle(color: AppColors.purple),)),
      ],
    );
  }
}
