import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_model.dart';

class HistoryList extends StatelessWidget {
  final List<LogModel> history;

  const HistoryList({super.key, required this.history});

  /// তারিখ এবং সময় ফরম্যাট করার ফাংশন
  String _formatDateTime(String rawDate) {
    if (rawDate.isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history_toggle_off, size: 50, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              const Text(
                  "No transactions available",
                  style: TextStyle(color: Colors.grey, fontSize: 13)
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          child: Text(
            "Recent Transactions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = history[index];
            bool isEmergency = item.isEmergency;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEmergency ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isEmergency ? Icons.emergency : Icons.local_gas_station,
                    color: isEmergency ? Colors.red : const Color(0xFF2D5C91),
                    size: 22,
                  ),
                ),
                title: Text(
                  item.vehiclePlate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _formatDateTime(item.dateTime),
                          style: const TextStyle(fontSize: 11, color: Colors.grey)
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.fuelType,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${item.liters}L",
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "৳${item.amount.toStringAsFixed(1)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D5C91),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEmergency ? "EMERGENCY" : "NORMAL",
                      style: TextStyle(
                        color: isEmergency ? Colors.red : Colors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // বিস্তারিত দেখার জন্য পরে ডায়ালগ বা নতুন স্ক্রিন যোগ করা যাবে
                },
              ),
            );
          },
        ),
      ],
    );
  }
}