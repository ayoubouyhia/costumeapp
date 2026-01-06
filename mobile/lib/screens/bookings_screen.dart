import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/database_helper.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final bookings = await DatabaseHelper.instance.getBookings();
    if (mounted) {
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBooking(int index) async {
    final booking = _bookings[index];
    await DatabaseHelper.instance.deleteBooking(booking.id!);
    setState(() {
      _bookings.removeAt(index);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin: All Bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No bookings found.'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple[100],
                          child: Text('${booking.id}'),
                        ),
                        title: Text('${booking.firstName} ${booking.lastName}'),
                        subtitle: Text('Total: ${booking.totalPrice.toStringAsFixed(0)} MAD'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBooking(index),
                        ),
                        children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _row('Size:', 'Jacket: ${booking.jacketSize} / Pants: ${booking.size}'),
                                  _row('Phone:', booking.phoneNumber),
                                  _row('Address:', booking.address),
                                  _row('Duration:', '${booking.durationDays} days'),
                                  _row('Date:', booking.startDate.toString().split(' ')[0]),
                                  _row('Status:', booking.status),
                                  const SizedBox(height: 8),
                                  _row('Costume ID:', '${booking.costumeId}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                    );
                  },
                ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
