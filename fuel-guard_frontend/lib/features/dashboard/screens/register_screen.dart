import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _isPasswordVisible = false;

  /// 🚀 অপারেটর অ্যাকাউন্ট অ্যাপ্লিকেশান হ্যান্ডলার
  void _handleApply() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    // ১. বেসিক ভ্যালিডেশন
    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      _showSnackBar("অনুগ্রহ করে সব তথ্য প্রদান করুন!", Colors.orange);
      return;
    }

    if (phone.length < 11) {
      _showSnackBar("সঠিক ফোন নম্বর প্রদান করুন (১১ ডিজিট)", Colors.orange);
      return;
    }

    if (password.length < 6) {
      _showSnackBar("পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.applyForAccount(name, phone, password);

      if (mounted) {
        // এপিআই যদি success true অথবা নতুন তৈরি হওয়া ID পাঠায়
        if (result['success'] == true || result.containsKey('id')) {
          _showSuccessDialog();
        } else {
          String errorMsg = result['message'] ?? result['error'] ?? "আবেদন ব্যর্থ হয়েছে";
          _showSnackBar(errorMsg, Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar("সার্ভার কানেকশন এরর! ইন্টারনেট চেক করুন।", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // সফলভাবে সাবমিট হলে পপআপ ডায়ালগ
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "আবেদন সফল হয়েছে!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "আপনার তথ্য অ্যাডমিনের কাছে পাঠানো হয়েছে। এপ্রুভ হওয়ার পর আপনি লগইন করতে পারবেন।",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ডায়ালগ বন্ধ করা
                Navigator.pop(context); // লগইন স্ক্রিনে ফিরে যাওয়া
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5C91),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("ঠিক আছে", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2D5C91);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Account Registration", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "নতুন অপারেটর অ্যাকাউন্ট",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              "নিচের ফর্মটি পূরণ করে সাবমিট করুন। অ্যাডমিন আপনার তথ্য যাচাই করে অ্যাকাউন্টটি চালু করবেন।",
              style: TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
            const SizedBox(height: 30),

            _buildInputField(
              controller: nameController,
              label: "আপনার পূর্ণ নাম",
              icon: Icons.person_outline,
              hint: "উদাঃ ইমন রানা",
              capitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 18),

            _buildInputField(
              controller: phoneController,
              label: "ফোন নম্বর",
              icon: Icons.phone_android,
              hint: "017XXXXXXXX",
              keyboardType: TextInputType.phone,
              maxLength: 11,
            ),
            const SizedBox(height: 18),

            _buildPasswordField(primaryColor),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text("আবেদন সাবমিট করুন", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textCapitalization: capitalization,
          decoration: InputDecoration(
            counterText: "", // maxLength এর ছোট লেখাটি লুকানোর জন্য
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF2D5C91)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2D5C91), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("পাসওয়ার্ড তৈরি করুন", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: "••••••••",
            prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}