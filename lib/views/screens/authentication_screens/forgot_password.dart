import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int currentStep = 1; // Track the current step of the flow (1: Enter Email, 2: Enter Code & Password)
  bool isLoading = false; // Show loading indicator while the request is being processed
  String generatedCode = ''; // Store the generated verification code

  // Function to generate a random 6-digit verification code
  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString(); // Generate a 6-digit code
  }

  // Function to send the reset code to the user's email
  Future<void> _sendResetCode() async {
    final email = emailController.text.trim();
    if (!_validateEmail(email)) {
      _showMessage('Email không hợp lệ! Vui lòng nhập đúng định dạng.'); // Invalid email message
      return;
    }

    setState(() => isLoading = true);
    generatedCode = _generateVerificationCode(); // Generate the verification code

    try {
      // Insert email and generated code into the email queue (you should send an email from here)
      await supabase.from('email_queue').insert({
        'email': email,
        'subject': 'Mã xác thực đặt lại mật khẩu',
        'message': 'Mã xác thực của bạn là: $generatedCode'
      });

      _showMessage('Mã xác thực đã được gửi đến email!'); // Success message
      setState(() => currentStep = 2); // Move to the next step (enter the code and new password)
    } catch (e) {
      _showMessage('Lỗi: ${e.toString()}'); // Error message if there's any issue
      print('Lỗi: ${e.toString()}');
    }

    setState(() => isLoading = false);
  }

  // Function to verify the code and reset the password
  Future<void> _verifyCodeAndResetPassword() async {
    final code = codeController.text.trim();
    final newPassword = passwordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty) {
      _showMessage('Vui lòng nhập mã xác thực và mật khẩu mới.'); // Missing code or password
      return;
    }

    if (code != generatedCode) {
      _showMessage('Mã xác thực không đúng! Vui lòng thử lại.'); // Code mismatch
      return;
    }

    setState(() => isLoading = true);

    try {
      // Update user's password in Supabase
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      _showMessage('Mật khẩu đã được cập nhật!'); // Password updated successfully
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login'); // Redirect to login screen
      });
    } catch (e) {
      _showMessage('Lỗi: ${e.toString()}'); // Error if something goes wrong
      print('Lỗi: ${e.toString()}');
    }

    setState(() => isLoading = false);
  }

  // Email validation using regular expression
  bool _validateEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    return regex.hasMatch(email);
  }

  // Displaying messages using Snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: const Text('Quên Mật Khẩu'), centerTitle: true),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                currentStep == 1
                    ? 'Nhập email của bạn để nhận mã xác thực'
                    : 'Nhập mã xác thực và mật khẩu mới',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (currentStep == 1)
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              if (currentStep == 2) ...[
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mã xác thực',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.security),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : currentStep == 1
                    ? _sendResetCode
                    : _verifyCodeAndResetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  backgroundColor: Colors.blueAccent,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(currentStep == 1 ? 'Gửi Mã' : 'Đổi Mật Khẩu', style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
