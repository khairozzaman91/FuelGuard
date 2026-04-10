import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String name;
  final String location;
  final String phone;
  final bool isActive; // সার্ভার থেকে স্ট্যাটাস ডাইনামিক করার জন্য

  const HeaderSection({
    super.key,
    required this.name,
    required this.location,
    required this.phone,
    this.isActive = true, // ডিফল্ট অ্যাক্টিভ থাকবে
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // একটু বেশি রাউন্ডেড মডার্ন লুকের জন্য
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // পাম্প আইকন বা লোগো
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                    Icons.local_gas_station_rounded,
                    color: Color(0xFF2D5C91),
                    size: 28
                ),
              ),
              const SizedBox(width: 15),

              // নাম এবং লোকেশন সেকশন
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? "Unknown Pump" : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // নাম অনেক বড় হলে ডট ডট দেখাবে
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.isEmpty ? "Location not available" : location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ডিভাইডার
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1, color: Color(0xFFF1F5F9), thickness: 1),
          ),

          // ফোন এবং স্ট্যাটাস সেকশন
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ফোন নম্বর
              Row(
                children: [
                  const Icon(Icons.phone_in_talk_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text(
                    phone.isEmpty ? "No Contact" : phone,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),

              // ডাইনামিক স্ট্যাটাস ট্যাগ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? "Active Now" : "Inactive",
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}