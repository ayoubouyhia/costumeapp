class Booking {
  final int? id;
  final int costumeId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;
  final DateTime startDate;
  final int durationDays;
  final double totalPrice;
  final String status; // 'Pending', 'Confirmed', etc.
  final String size; // Pant Size
  final String jacketSize;

  Booking({
    this.id,
    required this.costumeId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
    required this.startDate,
    required this.durationDays,
    required this.totalPrice,
    this.status = 'Pending',
    this.size = '40',
    this.jacketSize = 'M',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'costume_id': costumeId,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'address': address,
      'start_date': startDate.toIso8601String(),
      'duration_days': durationDays,
      'total_price': totalPrice,
      'status': status,
      'size': size,
      'jacket_size': jacketSize,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      costumeId: json['costume_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      startDate: DateTime.parse(json['start_date']),
      durationDays: json['duration_days'],
      totalPrice: json['total_price'],
      status: json['status'],
      size: json['size'] ?? '40',
      jacketSize: json['jacket_size'] ?? 'M',
    );
  }
}
