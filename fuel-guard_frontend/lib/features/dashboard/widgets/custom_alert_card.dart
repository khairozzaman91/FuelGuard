import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // তারিখ ফরম্যাট করার জন্য

class CustomAlertCard extends StatelessWidget {
  final String nextEligibleDate; // সার্ভার থেকে আসা তারিখ (উদাঃ 2026-04-12)

  const CustomAlertCard({
    super.key,
    required this.nextEligibleDate,
  });

  /// তারিখটিকে সুন্দর ফরম্যাটে দেখানোর ফাংশন
  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "N/A";
    try {
      DateTime dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMMM, yyyy').format(dateTime);
    } catch (e) {
      return dateStr; // ফরম্যাট করতে না পারলে যা আছে তাই দেখাবে
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ওয়ার্নিং আইকন সেকশন
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.block_flipped, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 15),

          // টেক্সট সেকশন
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "3-Day Rule Violation!",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 13,
                      height: 1.4, // লাইন গ্যাপ যেন সুন্দর লাগে
                    ),
                    children: [
                      const TextSpan(
                        text: "This vehicle has already taken fuel within the last 3 days. It is currently ",
                      ),
                      const TextSpan(
                        text: "BLOCKED",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: " from taking fuel.\n\n"),
                      const TextSpan(
                        text: "Next Eligible Date: ",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: _formatDate(nextEligibleDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}