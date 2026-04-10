class LogModel {
  final int id;
  final String vehiclePlate;
  final String stationId;
  final String operatorPhone;
  final String fuelType;
  final double liters;
  final double amount;
  final bool isEmergency;
  final String? emergencyReason;
  final String dateTime;

  LogModel({
    required this.id,
    required this.vehiclePlate,
    required this.stationId,
    required this.operatorPhone,
    required this.fuelType,
    required this.liters,
    required this.amount,
    required this.isEmergency,
    this.emergencyReason,
    required this.dateTime,
  });

  // --- API থেকে আসা JSON ডাটাকে মডেলে রূপান্তর ---
  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'] ?? 0,

      // SQL কলাম 'vehicle_plate' এর সাথে মিল রাখা হয়েছে
      vehiclePlate: (json['vehicle_plate'] ?? json['plate'] ?? '').toString(),

      // SQL কলাম 'station_id'
      stationId: (json['station_id'] ?? '').toString(),

      operatorPhone: (json['operator_phone'] ?? '').toString(),

      fuelType: (json['fuel_type'] ?? 'Octane').toString(),

      // Liters এবং Amount কে double এ কনভার্ট করা (যাতে ক্যালকুলেশনে এরর না আসে)
      liters: (json['liters'] ?? json['liter'] ?? 0.0).toDouble(),

      amount: (json['amount'] ?? 0.0).toDouble(),

      isEmergency: json['is_emergency'] == true || json['is_emergency'] == 1,

      emergencyReason: json['emergency_reason'] ?? json['reason'],

      // SQL কলাম 'created_at' বা 'transaction_date' যেটাই আসুক ধরবে
      dateTime: (json['created_at'] ?? json['transaction_date'] ?? json['date_time'] ?? '').toString(),
    );
  }

  // --- ব্যাকএন্ডে পাঠানোর জন্য JSON এ রূপান্তর ---
  Map<String, dynamic> toJson() {
    return {
      'vehicle_plate': vehiclePlate,
      'station_id': stationId,
      'operator_phone': operatorPhone,
      'fuel_type': fuelType,
      'liters': liters,
      'amount': amount,
      'is_emergency': isEmergency,
      'emergency_reason': emergencyReason,
      // 'created_at' ব্যাকএন্ড থেকে অটো জেনারেট হবে
    };
  }
}