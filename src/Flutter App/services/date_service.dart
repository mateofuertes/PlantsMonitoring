import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DateService {
    
    static Future<String> sendDate(String baseUrl) async {
    final String date = DateTime.now().toLocal().toString().split('.')[0];
    debugPrint(date);
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