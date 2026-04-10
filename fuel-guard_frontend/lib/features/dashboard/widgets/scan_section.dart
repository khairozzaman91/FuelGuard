import 'package:flutter/material.dart';

class ScanSection extends StatelessWidget {
  final VoidCallback onScan;
  final bool isLoading;

  const ScanSection({
    super.key,
    required this.onScan,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade100, width: 1.5),
      ),
      color: Colors.blue.shade50.withAlpha(128),
      child: InkWell(
        onTap: isLoading ? null : onScan,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.blue.shade100,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isLoading
                  ? const SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
                  : const Icon(
                Icons.qr_code_scanner_rounded,
                size: 48,
                color: Color(0xFF2D5C91),
              ),
              const SizedBox(height: 12),
              Text(
                isLoading ? "PROCESSING IMAGE..." : "TAP TO SCAN NUMBER PLATE",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                  color: Color(0xFF2D5C91),
                ),
              ),
              if (!isLoading) ...[
                const SizedBox(height: 4),
                Text(
                  "Align the plate within the camera frame",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700.withOpacity(0.8),
                  ),
                ),
              ],
              // এখানে এরর ছিল, ফিক্স করে দেওয়া হলো
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    "Hold steady for better accuracy",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}