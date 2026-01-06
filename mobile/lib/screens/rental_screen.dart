import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/costume.dart';
import '../models/booking.dart';
import '../services/database_helper.dart';

class RentalScreen extends StatefulWidget {
  final Costume costume;
  final String jacketSize;

  const RentalScreen({
    super.key, 
    required this.costume,
    required this.jacketSize,
  });

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Fields
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _address = '';
  int _durationDays = 1;
  String _selectedSize = '40'; // Default Pant Size (FR 40)

  bool _isLoading = false;

  double get _totalPrice => widget.costume.price * _durationDays;

  Future<void> _launchWhatsApp() async {
    final message = "Bonjour, je souhaite réserver le costume : *${widget.costume.name}*\nVeste : ${widget.jacketSize}\nPantalon : $_selectedSize\nDurée : $_durationDays jours.";
    final url = Uri.parse("https://wa.me/212718601741?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // 1. Create Booking Object
      final booking = Booking(
        costumeId: widget.costume.id,
        firstName: _firstName,
        lastName: _lastName,
        phoneNumber: _phone,
        address: _address,
        startDate: DateTime.now(),
        durationDays: _durationDays,
        totalPrice: _totalPrice,
        status: 'Confirmed', 
        size: _selectedSize, // Pant Size
        jacketSize: widget.jacketSize, // Jacket Size
      );

      // 2. Insert into DB
      await DatabaseHelper.instance.insertBooking(booking);

      // 3. Decrement Stock
      final newQuantity = widget.costume.quantity - 1;
      final updatedCostume = widget.costume.copyWith(
        quantity: newQuantity,
        isAvailable: newQuantity > 0,
      );
      await DatabaseHelper.instance.updateCostume(updatedCostume);

      if (!mounted) return;

      // 4. Success & Navigate Back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order confirmed! Payment due on delivery.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Booking'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Costume Application Summary
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Row(
                children: [
                   Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: (widget.costume.imagePath?.startsWith('http') ?? false)
                          ? DecorationImage(
                              image: NetworkImage(widget.costume.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (widget.costume.imagePath?.startsWith('http') ?? false)
                        ? null
                        : const Icon(Icons.checkroom, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.costume.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text('${widget.costume.price.toStringAsFixed(0)} MAD / day'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     // Size Selector
                    Text('Selected Jacket Size: ${widget.jacketSize}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 16),
                    
                    const Text('Select Pant Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSize,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: ['36', '38', '40', '42', '44', '46', '48'].map((String size) {
                        return DropdownMenuItem<String>(
                          value: size,
                          child: Text('Size $size'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSize = val!),
                    ),
                    const SizedBox(height: 24),

                    const Text('Your Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField(
                          label: 'First Name', 
                          onSaved: (v) => _firstName = v!,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(
                          label: 'Last Name', 
                          onSaved: (v) => _lastName = v!,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Phone Number', 
                      keyboardType: TextInputType.phone,
                      onSaved: (v) => _phone = v!,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Delivery Address', 
                      maxLines: 2,
                      onSaved: (v) => _address = v!,
                    ),
                    
                    const SizedBox(height: 32),
                    const Text('Rental Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    
                    Slider(
                      value: _durationDays.toDouble(),
                      min: 1,
                      max: 14,
                      divisions: 13,
                      label: '$_durationDays days',
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) => setState(() => _durationDays = val.round()),
                    ),
                    Center(child: Text('$_durationDays Days', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                    
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Invoice Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${_totalPrice.toStringAsFixed(0)} MAD', 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator.adaptive()
                          : const Text('Confirm Order (Pay on Delivery)', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: _launchWhatsApp,
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                        label: const Text('Book via WhatsApp', style: TextStyle(fontSize: 16, color: Colors.green)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required void Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      onSaved: onSaved,
    );
  }
}
