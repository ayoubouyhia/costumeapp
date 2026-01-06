import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'database_helper.dart';
import '../models/costume.dart';

class SyncService extends ChangeNotifier {
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // Helper for localhost based on platform
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  Future<void> syncData() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    final dio = Dio();

    try {
      print('Syncing with $_baseUrl');

      // 1. PUSH PENDING BOOKINGS
      final pendingBookings = await DatabaseHelper.instance.getPendingBookings();
      for (var booking in pendingBookings) {
        try {
          // Prepare guest payload
          final data = {
            'costume_id': booking.costumeId,
            'guest_name': '${booking.firstName} ${booking.lastName}',
            'guest_phone': booking.phoneNumber,
            'guest_address': booking.address,
            'start_date': booking.startDate.toIso8601String().split('T')[0],
            'expected_return_date': booking.startDate
                  .add(Duration(days: booking.durationDays))
                  .toIso8601String()
                  .split('T')[0],
          };

          await dio.post('$_baseUrl/guest-rentals', data: data);
          
          await DatabaseHelper.instance.updateBookingStatus(booking.id!, 'Synced');
          print('Synced booking ${booking.id}');
        } catch (e) {
          print('Failed to sync booking ${booking.id}: $e');
        }
      }


      // 2. FETCH COSTUMES - DISABLED TO PRESERVE LOCAL DATA
      // Note: Backend data is outdated (reverted). We use local source of truth.
      /*
      try {
        final response = await dio.get('$_baseUrl/costumes');
        if (response.statusCode == 200) {
          List<Costume> apiData = (response.data as List)
              .map((e) => Costume.fromJson(e))
              .toList();
          
          if (apiData.isNotEmpty) {
             await DatabaseHelper.instance.clearCostumes();
             for (var costume in apiData) {
               await DatabaseHelper.instance.insertCostume(costume);
             }
             print('Synced ${apiData.length} costumes from backend');
          }
        }
      } catch (e) {
         print('Failed to fetch costumes: $e');
         // If fetch fails, keep local data
      }
      */
      print('Skipping costume fetch to preserve local Golden Data.');
      
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

