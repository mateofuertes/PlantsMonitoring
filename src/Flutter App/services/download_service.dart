import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/foundation.dart';

class DownloadService {
  static Future<void> downloadImages(
      Map<String, List<String>> imagesByDate, String option, DateTime? startDate, DateTime? endDate) async {
    List<String> imagesToDownload = [];

    switch (option) {
      case 'all':
        imagesToDownload = imagesByDate.values.expand((images) => images).toList();
        break;
      case 'range':
        if (startDate != null && endDate != null) {
          imagesToDownload = imagesByDate.entries
              .where((entry) {
                DateTime date = DateTime.parse(entry.key);
                return date.isAfter(startDate.subtract(const Duration(days: 1))) && date.isBefore(endDate.add(const Duration(days: 1)));
              })
              .expand((entry) => entry.value)
              .toList();
        }
        break;
    }

    if (imagesToDownload.isNotEmpty) {
      await _createZip(imagesToDownload);
    }
  }

  static Future<void> _createZip(List<String> imageUrls) async {
    final tempDir = await getTemporaryDirectory();
    final zipFile = File('${tempDir.path}/images.zip');
    debugPrint('Creating zip file at: ${zipFile.path}');
    final archive = Archive();

    for (String imageUrl in imageUrls) {
      try {
        final response = await _fetchImageWithRetry(imageUrl);
        if (response != null && response.statusCode == 200) {
          final imageBytes = response.bodyBytes;
          final fileName = imageUrl.split('/').last;
          final archiveFile = ArchiveFile(fileName, imageBytes.length, imageBytes);
          archive.addFile(archiveFile);
        } else {
          debugPrint('Failed to download image: $imageUrl');
        }
      } catch (e) {
        debugPrint('Error downloading image $imageUrl: $e');
      }
    }

    final encoder = ZipEncoder();
    final zipData = encoder.encode(archive);

    if (zipData != null) {
      await zipFile.writeAsBytes(zipData);
      debugPrint('Zip file created at: ${zipFile.path}');
	  await _saveFileToExternalStorage(zipFile);
    } else {
      debugPrint('Failed to create zip file');
    }
  }

  static Future<void> _saveFileToExternalStorage(File file) async {
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    if (filePath != null) {
      debugPrint('File saved to: $filePath');
    } else {
      debugPrint('Failed to save file');
    }
  }

  static Future<http.Response?> _fetchImageWithRetry(String imageUrl, {int retries = 3}) async {
    int attempt = 0;
    while (attempt < retries) {
      attempt++;
      try {
        final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          return response;
        } else {
          debugPrint('Failed to fetch image: $imageUrl with status code: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Attempt $attempt - Error fetching image $imageUrl: $e');
        if (attempt >= retries) {
          rethrow;
        }
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

}
