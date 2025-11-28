import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEEFEEFF), // tu color actual
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Permite que todo el formulario se desplace si no cabe en altura
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500, // límite para web/desktop
                ),
                child: const LoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
