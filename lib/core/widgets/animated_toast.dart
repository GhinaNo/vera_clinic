import 'package:flutter/material.dart';
import 'custom_toast.dart';

class AnimatedToast extends StatefulWidget {
  final String message;
  final bool success;

  const AnimatedToast({Key? key, required this.message, this.success = false}) : super(key: key);

  @override
  State<AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<AnimatedToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      _controller.reverse().then((value) => _controller.dispose());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: CustomToast(
        message: widget.message,
        success: widget.success,
      ),
    );
  }
}
