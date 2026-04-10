import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../dashboard/screens/register_screen.dart';
import '../../admin/screens/admin_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isAdmin = false;
  bool isLoading = false;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  /// 🔐 লগইন হ্যান্ডলার
  Future<void> handleAuth() async {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showSnackBar("অনুগ্রহ করে আইডি এবং পাসওয়ার্ড দিন!");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.login(phone, password);

      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['user'];
        final String actualRole = (user['role'] ?? 'operator').toString().toLowerCase();
        final bool isApproved = user['is_approved'] ?? false;

        // ১. রোল ভ্যালিডেশন
        if (isAdmin && actualRole != 'admin') {
          _showSnackBar("আপনার এই আইডিটি অ্যাডমিন হিসেবে নিবন্ধিত নয়!");
          setState(() => isLoading = false);
          return;
        }

        if (!isAdmin && actualRole == 'admin') {
          _showSnackBar("আপনি অ্যাডমিন আইডি দিয়ে অপারেটর হিসেবে লগইন করার চেষ্টা করছেন। সুইচ অন করুন।");
          setState(() => isLoading = false);
          return;
        }

        // ২. নেভিগেশন লজিক
        if (actualRole == 'admin') {
          _showSnackBar("অ্যাডমিন হিসেবে লগইন সফল!");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
                (route) => false,
          );
        } else if (actualRole == 'operator') {
          if (isApproved) {
            _showSnackBar("স্বাগতম, অপারেটর!");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (route) => false,
            );
          } else {
            _showSnackBar("আপনার অ্যাকাউন্টটি এখনো পেন্ডিং। অ্যাডমিন এপ্রুভালের অপেক্ষা করুন।");
          }
        }
      } else {
        _showSnackBar(result['error'] ?? "লগইন ব্যর্থ হয়েছে");
      }
    } catch (e) {
      _showSnackBar("সার্ভারের সাথে সংযোগ বিচ্ছিন্ন। নেটওয়ার্ক চেক করুন!");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isAdmin ? Colors.red.shade800 : const Color(0xFF2D5C91),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = isAdmin ? Colors.red.shade800 : const Color(0xFF2D5C91);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(primaryColor),
              const SizedBox(height: 30),
              _buildRoleToggle(primaryColor), // এখানে আপডেট করা হয়েছে
              const SizedBox(height: 15),
              _buildForm(primaryColor),
              const SizedBox(height: 15),
              if (!isAdmin) _buildToggleText(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Color color) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.local_gas_station,
            size: 45,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "FuelGuard AI",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          isAdmin ? "Secure Admin Portal" : "Gas Station Operator",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRoleToggle(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "Operator",
              style: TextStyle(
                color: !isAdmin ? color : Colors.grey,
                fontWeight: !isAdmin ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Switch(
            value: isAdmin,
            onChanged: isLoading ? null : (v) { // লোডিং থাকলে সুইচ হবে না
              setState(() {
                isAdmin = v;
                phoneController.clear(); // সুইচ করলে ডাটা ক্লিয়ার
                passwordController.clear(); // সুইচ করলে ডাটা ক্লিয়ার
              });
            },
            activeColor: Colors.red.shade700,
            activeTrackColor: Colors.red.shade100,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              "Admin",
              style: TextStyle(
                color: isAdmin ? Colors.red : Colors.grey,
                fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          TextField(
            controller: phoneController,
            enabled: !isLoading, // লোডিং এর সময় টাইপ বন্ধ
            keyboardType: isAdmin ? TextInputType.text : TextInputType.phone,
            decoration: InputDecoration(
              labelText: isAdmin ? "Admin Username / Phone" : "Operator Phone Number",
              border: const OutlineInputBorder(),
              prefixIcon: Icon(isAdmin ? Icons.person_outline : Icons.phone_android, color: color),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: color, width: 2)),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: passwordController,
            enabled: !isLoading, // লোডিং এর সময় টাইপ বন্ধ
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline, color: color),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: color, width: 2)),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isLoading ? null : handleAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text(
                isAdmin ? "LOGIN AS ADMIN" : "LOGIN AS OPERATOR",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleText(Color color) {
    return TextButton(
      onPressed: isLoading ? null : () { // লোডিং থাকলে রেজিস্ট্রেশন বন্ধ
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      },
      child: RichText(
        text: TextSpan(
          text: "New Operator? ",
          style: const TextStyle(color: Colors.black54),
          children: [
            TextSpan(
              text: "Request Account",
              style: TextStyle(color: color, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
    );
  }
}