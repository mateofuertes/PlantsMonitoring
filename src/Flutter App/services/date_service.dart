import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// [DateService] handles interaction with the backend server for synchronizing the date of
/// the Raspberry Pi with the date of the phone.
class DateService {
    /// Sends the current date and time to the server to modify the date on the Raspberry Pi.
    static Future<String> sendDate(String baseUrl) async {
      /// Gets the current date and time.
      final String date = DateTime.now().toLocal().toString().split('.')[0];
      final response = await http.post(Uri.parse('$baseUrl/set_date'), body: {'new_date': date});
    if (response.statusCode == 200) {
      String result = json.decode(response.body);      
      return result;
    } else {
      String result = json.decode(response.body);
      return result;
    }
  }
}
