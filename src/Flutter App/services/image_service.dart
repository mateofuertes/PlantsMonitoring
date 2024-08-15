import 'dart:convert';
import 'package:app/utils/date_utils.dart';
import 'package:http/http.dart' as http;

class ImageService {
  
  static Future<Map<String, List<String>>> fetch(String baseUrl) async {
    
    final response = await http.get(Uri.parse('$baseUrl/images'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> allImages = data.map((item) => '$baseUrl/images/$item').toList();

      Map<String, List<String>> imagesByDate = {};
      for (String imageUrl in allImages) {
        String fileName = imageUrl.split('/').last;
        String datePart = MyDateUtils.extractDate(fileName);
        if (!imagesByDate.containsKey(datePart)) {
          imagesByDate[datePart] = [];
        }
        imagesByDate[datePart]!.add(imageUrl);
      }

      return imagesByDate;
    } else {
      throw Exception('Failed to load images');
    }
  }

}
