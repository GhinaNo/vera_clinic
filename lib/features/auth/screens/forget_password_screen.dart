import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../cubit/forget_password/forget_password_cubit.dart';
import '../cubit/forget_password/forget_password_state.dart';
import '../repository/auth_repository.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  void _sendCode(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      BlocProvider.of<ForgetPasswordCubit>(context)
          .forgetPassword(emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordCubit(AuthRepository()),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("نسيت كلمة المرور"),
              backgroundColor: AppColors.purple,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/login'),
              ),

            ),
            body: Container(
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
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                      listener: (context, state) {
                        setState(() => isLoading = false);
                        if (state is ForgetPasswordSuccess) {
                          showCustomToast(context, state.message, success: true);
                          context.go('/check-code', extra: emailController.text.trim());
                        } else if (state is ForgetPasswordFailure) {

                          String errorMsg = state.error;
                          if (errorMsg.contains("SocketException")) {
                            errorMsg = "تحقق من اتصال الإنترنت";
                          } else if (errorMsg.contains("email")) {
                            errorMsg = "البريد الإلكتروني غير صحيح";
                          } else {
                            errorMsg = "حدث خطأ، حاول مرة أخرى";
                          }
                          showCustomToast(context, errorMsg, success: false);
                        }
                      },
                      builder: (context, state) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "أدخل بريدك الإلكتروني لإرسال كود التحقق:",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "البريد الإلكتروني",
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال البريد الإلكتروني';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                                      .hasMatch(value)) {
                                    return 'البريد الإلكتروني غير صالح';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => _sendCode(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purple,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "إرسال الكود",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.purple,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
