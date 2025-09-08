import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vera_clinic/features/auth/repository/auth_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_toast.dart';
import 'cubit/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(AuthRepository()),
      child: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      context.read<LoginCubit>().login(
        email: email,
        password: password,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
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
                    width: screenWidth > 900 ? 900 : screenWidth * 0.95,
                    height: screenHeight > 600 ? 500 : null,
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
                    child: BlocConsumer<LoginCubit, LoginState>(
                      listener: (context, state) {
                        setState(() => isLoading = false);
                        if (state is LoginSuccess) {
                          final loginResponse = state.loginResponse;
                          showCustomToast(context, 'تم تسجيل الدخول بنجاح', success: true);

                          if (loginResponse.role == "admin") {
                            context.go('/admin-home', extra: {
                              'token': loginResponse.token,
                              'role': loginResponse.role,
                            });
                          } else if (loginResponse.role == "receptionist") {
                            context.go('/reception-home', extra: {
                              'token': loginResponse.token,
                              'role': loginResponse.role,
                            });
                          } else {
                            context.go('/home', extra: {
                              'token': loginResponse.token,
                              'role': loginResponse.role,
                            });
                          }
                        } else if (state is LoginFailure) {
                          showCustomToast(context, state.error, success: false);
                        }
                      },
                      builder: (context, state) {
                        return screenWidth > 600
                            ? Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.purple,
                                      AppColors.purple.withOpacity(0.85)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/logo.png',
                                      width: 120,
                                      height: 120,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      "VERA CLINIC",
                                      style: TextStyle(
                                        color: AppColors.offWhite,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "إدارة مركز فيرا-درعا",
                                      style: TextStyle(
                                        color: AppColors.offWhite.withOpacity(0.9),
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: _buildForm(context),
                              ),
                            ),
                          ],
                        )
                            : Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildForm(context),
                        );
                      },
                    ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.purple,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "جاري تسجيل الدخول...",
                      style: TextStyle(
                        color: AppColors.offWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "تسجيل الدخول",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              labelText: "البريد الإلكتروني",
              prefixIcon: Icon(Icons.email, color: Colors.black54),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                return 'البريد الإلكتروني غير صالح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: "كلمة المرور",
              prefixIcon: const Icon(Icons.lock, color: Colors.black54),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "تسجيل الدخول",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/forget-password'),
            child: Text(
              "نسيت كلمة المرور؟",
              style: TextStyle(color: AppColors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
