import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../cubit/reset_password/reset_password_cubit.dart';
import '../cubit/reset_password/reset_password_state.dart';
import '../repository/auth_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String code;
  const ResetPasswordScreen({super.key, required this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(AuthRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إعادة تعيين كلمة المرور"),
          backgroundColor: AppColors.purple,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/check-code'),
          ),
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.offWhite.withOpacity(0.95),
                    AppColors.beige.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                      listener: (context, state) {
                        if (state is ResetPasswordSuccess) {
                          showCustomToast(context, state.message, success: true);
                          context.go('/login');
                        } else if (state is ResetPasswordFailure) {
                          showCustomToast(context, state.error, success: false);
                        }
                      },
                      builder: (context, state) {
                        if (state is ResetPasswordLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.purple,
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "أدخل كلمة المرور الجديدة:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                labelText: "كلمة المرور الجديدة",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: confirmController,
                              obscureText: obscureConfirm,
                              decoration: InputDecoration(
                                labelText: "تأكيد كلمة المرور",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirm
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureConfirm = !obscureConfirm;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                final pass = passwordController.text.trim();
                                final confirm = confirmController.text.trim();

                                if (pass.isEmpty || confirm.isEmpty) {
                                  showCustomToast(context, "املأ جميع الحقول");
                                  return;
                                }
                                if (pass != confirm) {
                                  showCustomToast(
                                      context, "كلمتا المرور غير متطابقتين");
                                  return;
                                }

                                context
                                    .read<ResetPasswordCubit>()
                                    .resetPassword(widget.code, pass, confirm);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.purple,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "تغيير كلمة المرور",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
