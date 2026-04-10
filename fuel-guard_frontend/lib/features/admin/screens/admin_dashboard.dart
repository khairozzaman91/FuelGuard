import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api_service.dart';
import '../../dashboard/screens/station_details_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedFilter = "Today";
  List pendingOperators = [];
  List liveStations = [];
  bool isLoading = true;

  double totalLiters = 0;
  int totalCars = 0;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      await Future.wait([
        _fetchPendingUsers(),
        _fetchLiveStats(),
      ]);
    } catch (e) {
      _showSnackBar("ডাটা লোড করতে সমস্যা হয়েছে", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchPendingUsers() async {
    final users = await ApiService.getPendingOperators();
    setState(() {
      pendingOperators = users;
    });
  }

  Future<void> _fetchLiveStats() async {
    final stats = await ApiService.getLiveStats();

    double litersCount = 0;
    int carsCount = 0;

    for (var item in stats) {
      litersCount += (item['total_liters'] ?? 0).toDouble();
      num cars = item['total_cars'] ?? 0;
      carsCount += cars.toInt();
    }

    setState(() {
      liveStations = stats;
      totalLiters = litersCount;
      totalCars = carsCount;
    });
  }

  // ✅ আপডেট: userId এখন String (UUID) গ্রহণ করবে
  Future<void> _approveUser(String userId) async {
    if (userId.isEmpty) return;

    final success = await ApiService.approveOperator(userId);
    if (success) {
      _showSnackBar("অপারেটর সফলভাবে এপ্রুভ হয়েছে!", Colors.green);
      _fetchAdminData();
    } else {
      _showSnackBar("এপ্রুভ করা সম্ভব হয়নি", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Admin Control Panel",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D5C91),
        actions: [
          IconButton(onPressed: _fetchAdminData, icon: const Icon(Icons.refresh, color: Colors.white))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAdminData,
        color: const Color(0xFF2D5C91),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSummaryCard("Today's Sale", "${totalLiters.toStringAsFixed(1)} L", Colors.blue.shade700, Icons.speed),
                  const SizedBox(width: 10),
                  _buildSummaryCard("Total Cars", "$totalCars", Colors.orange.shade800, Icons.directions_car),
                ],
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("Operator Requests", "Pending Approval"),
              const SizedBox(height: 10),
              pendingOperators.isEmpty
                  ? const Card(child: ListTile(title: Text("কোন পেন্ডিং রিকোয়েস্ট নেই", style: TextStyle(fontSize: 13, color: Colors.grey))))
                  : Column(
                children: pendingOperators.map((user) {
                  // ✅ আপডেট: ID-কে সেফলি String-এ রূপান্তর (UUID হ্যান্ডলিং)
                  String id = user['id']?.toString() ?? user['ID']?.toString() ?? "";
                  return _buildPendingPumpItem(
                    context,
                    user['full_name'] ?? "Unknown",
                    user['phone'] ?? "N/A",
                    user['pump_name'] ?? user['location'] ?? "Unknown Pump",
                    id,
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("Live Monitoring", "Real-time updates"),
                  _buildSortDropdown(),
                ],
              ),
              const SizedBox(height: 10),
              liveStations.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("আজ কোন তেল বিক্রি হয়নি")))
                  : Column(
                children: liveStations.map((station) {
                  return _buildLiveStationItem(
                    station['station_id'] ?? "Unknown",
                    "${station['total_liters'] ?? 0}L",
                    "${station['total_cars'] ?? 0} Cars",
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButton<String>(
        value: _selectedFilter,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
        items: ["Today", "2 Days", "3 Days"].map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: (val) {
          setState(() => _selectedFilter = val!);
          _fetchLiveStats();
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white54, size: 18),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ✅ আপডেট: id প্যারামিটার এখন String
  Widget _buildPendingPumpItem(BuildContext context, String name, String phone, String location, String id) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("$phone | $location", style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.call, color: Colors.green, size: 20), onPressed: () => _makeCall(phone)),
            ElevatedButton(
              onPressed: id.isEmpty ? null : () => _approveUser(id),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5C91), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              child: const Text("Approve", style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStationItem(String name, String liters, String cars) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StationDetailsScreen(
                stationId: name,
                stationName: "Station $name",
              ),
            ),
          );
        },
        leading: const Icon(Icons.sensors, size: 18, color: Colors.green),
        title: Text("Station ID: $name", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Total: $liters | $cars", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF2D5C91))),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}