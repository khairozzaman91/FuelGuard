import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'package:intl/intl.dart';

class StationDetailsScreen extends StatefulWidget {
  final String stationName;
  final String stationId;

  const StationDetailsScreen({
    super.key,
    required this.stationName,
    required this.stationId
  });

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  int _selectedDays = 1;
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // ১. এপিআই থেকে ডাটা ফেচ করা
  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // এপিআই কল করার সময় ফিল্টার ডেইজ পাঠানো হচ্ছে
      final data = await ApiService.getStationDetails(widget.stationId, _selectedDays);
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError("ইতিহাস লোড করা সম্ভব হয়নি");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
    );
  }

  // মোট ফুয়েল ক্যালকুলেট করার সেফ মেথড
  String _calculateTotalFuel() {
    double total = 0;
    for (var item in _transactions) {
      // liters অথবা amount যাই হোক, ডাবল হিসেবে কনভার্ট করে যোগ করা
      total += (item['liters'] ?? 0).toDouble();
    }
    return total.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.stationName, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            Text("Station ID: ${widget.stationId}", style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF2D5C91),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // --- ফিল্টার সেকশন ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            child: Column(
              children: [
                const Text("Select History Range", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterButton("Today", 1),
                    const SizedBox(width: 8),
                    _buildFilterButton("2 Days", 2),
                    const SizedBox(width: 8),
                    _buildFilterButton("3 Days", 3),
                  ],
                ),
              ],
            ),
          ),

          // --- সামারি স্ট্যাটাস ---
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                _buildSummaryStat("Cars Served", "${_transactions.length}", Colors.blue),
                const SizedBox(width: 10),
                _buildSummaryStat("Total Volume", "${_calculateTotalFuel()} L", Colors.green),
              ],
            ),
          ),

          // --- ট্রানজেকশন লিস্ট ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              itemCount: _transactions.length,
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                return _buildCarLogItem(_transactions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, int days) {
    bool isSelected = _selectedDays == days;
    return InkWell(
      onTap: () {
        if (_selectedDays != days) {
          setState(() => _selectedDays = days);
          _fetchHistory();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D5C91) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF2D5C91) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCarLogItem(Map<String, dynamic> tx) {
    bool isEmergency = tx['is_emergency'] ?? false;

    // টাইম হ্যান্ডলিং: created_at অথবা date_time যেকোনো একটি থাকলেও কাজ করবে
    String rawDate = tx['created_at'] ?? tx['date_time'] ?? "";
    String formattedTime = "Unknown Time";

    if(rawDate.isNotEmpty){
      try {
        DateTime date = DateTime.parse(rawDate).toLocal();
        formattedTime = DateFormat('dd MMM, hh:mm a').format(date);
      } catch (e) {
        formattedTime = rawDate;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isEmergency ? Colors.red.shade300 : Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEmergency ? Colors.red.shade50 : Colors.blue.shade50,
          child: Icon(
            isEmergency ? Icons.emergency : Icons.directions_car,
            color: isEmergency ? Colors.red : const Color(0xFF2D5C91),
            size: 20,
          ),
        ),
        title: Text(
            tx['vehicle_plate'] ?? "No Plate",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Slot: ${tx['assigned_slot'] ?? 'N/A'} • $formattedTime", style: const TextStyle(fontSize: 11)),
            if (isEmergency)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text("Reason: ${tx['emergency_reason'] ?? 'Emergency'}",
                    style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w500)),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${tx['liters'] ?? 0}L",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
            Text("${tx['fuel_type'] ?? 'Fuel'}",
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text("কোনো তথ্য পাওয়া যায়নি", style: TextStyle(color: Colors.grey, fontSize: 14)),
          Text("Day Range: $_selectedDays", style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}