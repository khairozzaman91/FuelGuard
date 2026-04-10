import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ এমুলেটর হলে 10.0.2.2 ব্যবহার করো, রিয়েল ডিভাইসে পিসির IPv4 এড্রেস দাও
  static const String baseUrl = "http://10.0.2.2:8080/api/v1";

  // টোকেন গেট করার জন্য ইন্টারনাল হেল্পার মেথড
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // রিকোয়েস্ট হেডার তৈরি করার মেথড (JWT Auth এর জন্য)
  static Future<Map<String, String>> _headers() async {
    String? token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ================= AUTH METHODS =================

  /// 1. User Login
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // ব্যাকএন্ড থেকে আসা টোকেন এবং রোল সেভ করা
        await prefs.setString('jwt_token', data['data']['token']);
        await prefs.setString('user_role', data['data']['user']['role']);
        await prefs.setBool('is_approved', data['data']['user']['is_approved'] ?? false);
        return {"success": true, "user": data['data']['user']};
      } else {
        return {"success": false, "error": data['error'] ?? "লগইন ব্যর্থ হয়েছে"};
      }
    } catch (e) {
      return {"success": false, "error": "সার্ভারের সাথে কানেক্ট করা যাচ্ছে না!"};
    }
  }

  /// 2. Register (অ্যাকাউন্টের আবেদন)
  static Future<Map<String, dynamic>> applyForAccount(String name, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": name,
          "phone": phone,
          "password": password,
          "role": "operator"
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": "রেজিস্ট্রেশন এরর: $e"};
    }
  }

  // ================= ADMIN ONLY METHODS =================

  /// 3. Get Pending Operators
  static Future<List<dynamic>> getPendingOperators() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/pending"),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 4. Approve Operator (সংশোধিত: এখন String টাইপ আইডি নিবে)
  static Future<bool> approveOperator(String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/approve"),
        headers: await _headers(),
        body: jsonEncode({"user_id": userId}), // ব্যাকএন্ডে key 'user_id' হিসেবে রিসিভ করে
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 5. Get Live Monitoring Stats
  static Future<List<dynamic>> getLiveStats() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/live-stats"),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 6. Get Station Detail
  static Future<List<dynamic>> getStationDetails(String stationId, int days) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/station/$stationId?days=$days"),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ================= OPERATOR & TRANSACTION METHODS =================

  /// 7. Check Eligibility (গাড়ি আজ তেল পাবে কি না)
  static Future<Map<String, dynamic>> checkEligibility(String plate) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/check-eligibility"),
        headers: await _headers(),
        body: jsonEncode({"vehicle_plate": plate}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": "সার্ভার এরর"};
    }
  }

  /// 8. Submit Fuel Entry (ট্রানজ্যাকশন সেভ করা)
  static Future<Map<String, dynamic>> submitFuelEntry(Map<String, dynamic> fuelData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/submit-fuel"),
        headers: await _headers(),
        body: jsonEncode(fuelData),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": "সাবমিট করা যায়নি: $e"};
    }
  }

  /// 9. Get Fuel History (পাম্পের বা ইউজারের হিস্ট্রি দেখা)
  static Future<List<dynamic>> getFuelHistory({String? stationId}) async {
    try {
      String url = "$baseUrl/fuel-history";
      if (stationId != null) url += "?station_id=$stationId";

      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // নোট: ব্যাকএন্ডে transaction_date কলাম ব্যবহার হচ্ছে, ফ্রন্টএন্ড মডেলে এটি খেয়াল রাখতে হবে
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ================= PROFILE METHODS =================

  /// 10. Get Profile (অপারেটরের নিজের তথ্য)
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile"),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// 11. Update Profile (প্রোফাইল আপডেট)
  static Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      // ব্যাকএন্ডে রুট অনুযায়ী /update-pump-profile হতে পারে, চেক করে নিন
      final response = await http.post(
        Uri.parse("$baseUrl/update-pump-profile"),
        headers: await _headers(),
        body: jsonEncode(profileData),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 12. Logout
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}