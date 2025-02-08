import 'package:education_app/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const routeName = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Center(
        child: Text(
          'SIGN UP SCREEN',
          style:
              context.theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
