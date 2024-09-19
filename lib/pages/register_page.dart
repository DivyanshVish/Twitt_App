import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitt/components/my_buttons.dart';
import 'package:twitt/components/my_text_field.dart';
import 'package:twitt/provider/auth_provider.dart';
import 'package:twitt/services/auth/auth_services.dart';
import 'package:twitt/services/database/database_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _db = DatabaseService();
  final _auth = AuthServices();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void register() async {
    try {
      if (context.read<AuthProvider>().isLoading) {
        return;
      }
      if (passwordController.text.isEmpty) {
        throw "Password is required";
      }
      if (emailController.text.isEmpty) {
        throw "Email is required";
      }
      if (nameController.text.isEmpty) {
        throw "Name is required";
      }
      if (confirmpassController.text.isEmpty) {
        throw "Confirm Password is required";
      }
      if (passwordController.text != confirmpassController.text) {
        throw "Password does not match";
      }

      context.read<AuthProvider>().isLoading = true;

      final res = await _auth.registerEmailPassword(
        emailController.text,
        passwordController.text,
      );

      await _db.saveUserInfoInFirebase(
        name: res.user?.displayName ?? nameController.text,
        email: res.user?.email ?? emailController.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) context.read<AuthProvider>().isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Icon(
                    Icons.lock_open_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Welcome back you/'ve been missed",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    maxLength: 10,
                    enabled: !context.watch<AuthProvider>().isLoading,
                    hintText: 'Enter Name.....',
                    controller: nameController,
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    maxLength: 30,
                    enabled: !context.watch<AuthProvider>().isLoading,
                    hintText: 'Enter Email.....',
                    controller: emailController,
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    maxLength: 20,
                    enabled: !context.watch<AuthProvider>().isLoading,
                    hintText: 'Enter Password.....',
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    maxLength: 20,
                    enabled: !context.watch<AuthProvider>().isLoading,
                    hintText: 'Confirm Password.....',
                    controller: confirmpassController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  MyButtons(
                    text: 'Register',
                    onTap: register,
                    isLoading: context.watch<AuthProvider>().isLoading,
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already a member?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Login here",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
