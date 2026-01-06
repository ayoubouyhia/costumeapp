import 'package:flutter/material.dart';
import '../models/costume.dart';
import 'rental_screen.dart';

class DetailScreen extends StatefulWidget {
  final Costume costume;

  const DetailScreen({super.key, required this.costume});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _selectedJacketSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.costume.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[300],
              child: (widget.costume.imagePath != null && widget.costume.imagePath!.startsWith('http'))
                  ? Image.network(
                      widget.costume.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => const Center(child: Icon(Icons.broken_image, size: 50)),
                    )
                  : const Center(child: Icon(Icons.image, size: 100)),
            ),
            const SizedBox(height: 16),
            Text(
              widget.costume.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${widget.costume.price.toStringAsFixed(0)} MAD / jour',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green),
            ),
            const SizedBox(height: 8),
            
            // Jacket Size Selector
            const Text('Select Jacket Size', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedJacketSize,
              hint: const Text('Choose Jacket Size (S-XXL)'),
              items: ['S', 'M', 'L', 'XL', 'XXL'].map((String size) {
                return DropdownMenuItem<String>(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedJacketSize = val),
            ),

            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.costume.description ?? 'No description available.'),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (widget.costume.isAvailable && widget.costume.quantity > 0 && _selectedJacketSize != null)
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RentalScreen(
                              costume: widget.costume, 
                              jacketSize: _selectedJacketSize!
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (widget.costume.isAvailable && widget.costume.quantity > 0 && _selectedJacketSize != null) ? null : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text((widget.costume.isAvailable && widget.costume.quantity > 0) 
                  ? (_selectedJacketSize == null ? 'Select Jacket Size' : 'Rent This Costume (${widget.costume.quantity} left)') 
                  : 'Out of Stock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

