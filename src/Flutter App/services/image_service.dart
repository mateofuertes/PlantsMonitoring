import 'dart:convert';
import 'package:app/utils/date_utils.dart';
import 'package:http/http.dart' as http;

/// [ImageService] handles interaction with the Raspberry Pi server to fetch the images
/// stored on the device. It retrieves image data and organizes it by date.
class ImageService {
  /// Fetches a map of images from the server, categorized by date.
  static Future<Map<String, List<String>>> fetch(String baseUrl) async {
    // Send a GET request to the server to retrieve the list of images.
    final response = await http.get(Uri.parse('$baseUrl/images'));
    
    if (response.statusCode == 200) {
      
      List<dynamic> data = json.decode(response.body);

      // Create a list of full image URLs by combining the base URL with the image filenames.
      List<String> allImages = data.map((item) => '$baseUrl/images/$item').toList();

      // Initialize an empty map to store images categorized by date.
      Map<String, List<String>> imagesByDate = {};

      // Iterate over each image URL.
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
