import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../cubit/check_code/check_code_cubit.dart';
import '../cubit/check_code/check_code_state.dart';
import '../repository/auth_repository.dart';

class CheckCodeScreen extends StatelessWidget {
  CheckCodeScreen({super.key});
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckCodeCubit(AuthRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("أدخل كود التحقق"),
          backgroundColor: AppColors.purple,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go( '/forget-password'),
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
                    child: BlocConsumer<CheckCodeCubit, CheckCodeState>(
                      listener: (context, state) {
                        if (state is CheckCodeSuccess) {
                          showCustomToast(context, state.message, success: true);
                          final code = context.read<CheckCodeCubit>().verifiedCode;
                          if (code != null && code.isNotEmpty) {
                            context.go('/reset-password', extra: code);
                          } else {
                            showCustomToast(context, "الكود غير صالح", success: false);
                          }
                        } else if (state is CheckCodeFailure) {
                          showCustomToast(context, state.error, success: false);
                        }
                      },
                      builder: (context, state) {
                        if (state is CheckCodeLoading) {
                          return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.purple,
                              ));
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "أدخل الكود الذي تم إرساله إلى بريدك الإلكتروني:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: codeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "الكود",
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                final code = codeController.text.trim();
                                if (code.isEmpty) {
                                  showCustomToast(
                                      context, "أدخل الكود أولاً");
                                } else {
                                  context.read<CheckCodeCubit>().checkCode(code);
                                }
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
                                "تحقق",
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
