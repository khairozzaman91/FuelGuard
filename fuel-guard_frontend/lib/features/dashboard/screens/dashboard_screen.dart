import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import '../../../services/ocr_service.dart';
import '../models/log_model.dart';
import '../widgets/history_list.dart';
import '../widgets/scan_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // সার্ভিস এবং হেল্পার অবজেক্ট
  final OCRService _ocrService = OCRService();
  final ImagePicker _picker = ImagePicker();

  String pumpName = "Loading...";
  String pumpLocation = "Connecting...";
  String pumpNumber = "---";
  String operatorPhone = "";

  final TextEditingController _literController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool isBlocked = false;
  bool showInputForm = false;
  bool isEmergencyMode = false;
  bool isLoading = false;
  String scannedPlate = "";
  String nextAvailableDate = "N/A";
  String blockMessage = "";
  String selectedFuelType = "Octane";

  List<LogModel> fuelHistory = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _literController.dispose();
    _reasonController.dispose();
    _amountController.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  // ১. ডাটা লোড করা
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final profile = await ApiService.getProfile();
      final List<dynamic> historyData = await ApiService.getFuelHistory();

      setState(() {
        pumpName = profile['pump_name'] ?? "Pump Station";
        pumpLocation = profile['location'] ?? "Unknown";
        pumpNumber = profile['station_id'] ?? "---";
        operatorPhone = profile['phone'] ?? "";
        fuelHistory = historyData.map((j) => LogModel.fromJson(j)).toList();
      });
    } catch (e) {
      _showSnackBar("ডাটা আপডেট করতে সমস্যা হয়েছে!", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ২. আজ কত লিটার ও কয়টি গাড়ি হলো তার হিসাব
  Map<String, dynamic> _getTodayStats() {
    double totalLiters = 0;
    int totalCars = 0;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (var log in fuelHistory) {
      if (log.dateTime.contains(today)) {
        totalCars++;
        totalLiters += log.liters;
      }
    }
    return {"cars": totalCars, "liters": totalLiters.toStringAsFixed(1)};
  }

  // ৩. ক্যামেরা দিয়ে প্লেট স্ক্যান করার লজিক
  Future<void> _handleCameraScan() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => isLoading = true);

      String? result = await _ocrService.scanNumberPlate(image.path);

      if (result != null) {
        _showSnackBar("প্লেট নম্বর পাওয়া গেছে: $result");
        _handleScanCheck(result);
      } else {
        _showSnackBar("নম্বর পড়া সম্ভব হয়নি! ম্যানুয়ালি ট্রাই করুন।", isError: true);
        _showManualPlateDialog();
      }
    } catch (e) {
      _showSnackBar("স্ক্যানিং এরর!", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ৪. গাড়ি চেক করা (এপিআই কল)
  void _handleScanCheck(String plate) async {
    if (plate.isEmpty) return;
    setState(() {
      scannedPlate = plate;
      isLoading = true;
      isEmergencyMode = false;
    });

    try {
      final response = await ApiService.checkEligibility(plate);

      if (response['eligible'] == false) {
        setState(() {
          isBlocked = true;
          showInputForm = false;
          blockMessage = response['message'] ?? "৩ দিনের নিয়ম লঙ্ঘন!";
          nextAvailableDate = response['next_eligible_date'] ?? "N/A";
        });
        _showSnackBar("এই গাড়িটি ব্লকড!", isError: true);
      } else {
        setState(() {
          isBlocked = false;
          showInputForm = true;
        });
        _showSnackBar("গাড়িটি অনুমোদিত ✅");
      }
    } catch (e) {
      _showSnackBar("সার্ভার কানেকশন এরর!", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ৫. ফুয়েল এন্ট্রি সাবমিট
  void _handleSubmit() async {
    if (_literController.text.isEmpty || _amountController.text.isEmpty) {
      _showSnackBar("লিটার এবং টাকার পরিমাণ লিখুন", isError: true);
      return;
    }

    setState(() => isLoading = true);

    final fuelData = {
      "vehicle_plate": scannedPlate,
      "liters": double.tryParse(_literController.text) ?? 0,
      "amount": double.tryParse(_amountController.text) ?? 0,
      "fuel_type": selectedFuelType,
      "operator_phone": operatorPhone,
      "is_emergency": isEmergencyMode,
      "emergency_reason": isEmergencyMode ? _reasonController.text : "Normal",
      "station_id": pumpNumber,
    };

    try {
      final result = await ApiService.submitFuelEntry(fuelData);
      if (result['success'] == true) {
        _showScheduleDialog(
            result['data']['next_eligible_date'] ?? "N/A",
            result['data']['assigned_slot'] ?? "N/A"
        );
        _loadInitialData();
        _resetForm();
      } else {
        _showSnackBar(result['error'] ?? "সাবমিট ব্যর্থ হয়েছে", isError: true);
      }
    } catch (e) {
      _showSnackBar("সাবমিট এরর!", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      showInputForm = false;
      isBlocked = false;
      isEmergencyMode = false;
      scannedPlate = "";
      _literController.clear();
      _reasonController.clear();
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getTodayStats();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2D5C91),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pumpName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(pumpLocation, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadInitialData, icon: const Icon(Icons.refresh, color: Colors.white)),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (isLoading) const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: LinearProgressIndicator(color: Colors.orange),
              ),
              _buildSummaryCard(stats),
              const SizedBox(height: 15),

              ScanSection(
                onScan: _handleCameraScan,
                isLoading: isLoading,
              ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: _showManualPlateDialog,
                icon: const Icon(Icons.edit_note),
                label: const Text("OR ENTER PLATE MANUALLY"),
              ),

              const SizedBox(height: 15),

              if (isBlocked && !isEmergencyMode) _buildBlockedUI(),
              if (showInputForm || isEmergencyMode) _buildEntryForm(),

              const SizedBox(height: 10),
              HistoryList(history: fuelHistory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Today's Cars", "${stats['cars']}", Colors.blue),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildStatItem("Total Liters", "${stats['liters']}L", Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildBlockedUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
      child: Column(children: [
        const Icon(Icons.warning, color: Colors.red, size: 30),
        const SizedBox(height: 5),
        Text(blockMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text("পরবর্তীতে তেল পাবে: $nextAvailableDate", style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => setState(() => isEmergencyMode = true),
          icon: const Icon(Icons.emergency, color: Colors.orange),
          label: const Text("Emergency Override", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        )
      ]),
    );
  }

  Widget _buildEntryForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Vehicle: $scannedPlate", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (isEmergencyMode) const Badge(label: Text("Emergency"), backgroundColor: Colors.red),
            ],
          ),
          const Divider(),

          // এখানে 'value' এর বদলে 'initialValue' ব্যবহার করা হয়েছে
          DropdownButtonFormField<String>(
            key: UniqueKey(), // রিফ্রেশ এর জন্য কি ব্যবহার করা যেতে পারে
            initialValue: selectedFuelType,
            decoration: const InputDecoration(labelText: "Fuel Type"),
            items: ["Octane", "Diesel", "Petrol"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => selectedFuelType = val!),
          ),

          TextField(controller: _literController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Liters", suffixText: "L")),
          TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Total Amount", suffixText: "BDT")),
          if (isEmergencyMode) TextField(controller: _reasonController, decoration: const InputDecoration(labelText: "Emergency Reason")),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: _resetForm, child: const Text("Cancel"))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("SUBMIT RECORD"),
              )),
            ],
          )
        ]),
      ),
    );
  }

  void _showManualPlateDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Check Number Plate"),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(hintText: "Ex: DHAKA-METRO-1234"),
        textCapitalization: TextCapitalization.characters,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
        ElevatedButton(onPressed: () {
          Navigator.pop(c);
          _handleScanCheck(ctrl.text.trim().toUpperCase());
        }, child: const Text("Check")),
      ],
    ));
  }

  void _showSnackBar(String m, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showScheduleDialog(String date, String slot) {
    showDialog(context: context, builder: (c) => AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
      title: const Text("Transaction Successful"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("গাড়ির রেকর্ড সেভ করা হয়েছে।"),
          const SizedBox(height: 10),
          Text("Next Date: $date", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Assigned Slot: $slot"),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
    ));
  }

  void _handleLogout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Yes")),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.logout();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}