import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/foundation.dart';

/// [DownloadService] is responsible for downloading images from a server,
/// creating a zip archive of the images, and saving the archive to external storage.
class DownloadService {
    /// Downloads and zips images based on the selected option ('all' or 'range').
    static Future<void> downloadImages(
      Map<String, List<String>> imagesByDate, String option, DateTime? startDate, DateTime? endDate) async {
    List<String> imagesToDownload = [];
	    
    // Determine which images to download based on the selected option
    switch (option) {
      case 'all':
        imagesToDownload = imagesByDate.values.expand((images) => images).toList();
        break;
      case 'range':
        // Download images within the specified date range.
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

    // If there are images to download, proceed with creating a zip file.
    if (imagesToDownload.isNotEmpty) {
      await _createZip(imagesToDownload);
    }
  }

  /// Creates a zip archive from the provided list of image URLs.
  /// Downloads each image and adds it to an [Archive] object. Once all images are added,
  /// the archive is compressed into a zip file and saved temporarily. The zip file is
  /// then passed to `_saveFileToExternalStorage` for external storage.
  static Future<void> _createZip(List<String> imageUrls) async {
    final tempDir = await getTemporaryDirectory();
    final zipFile = File('${tempDir.path}/images.zip');
    final archive = Archive();

    // Download each image and add it to the archive.
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
	  
    // Encode the archive into a zip file
    final encoder = ZipEncoder();
    final zipData = encoder.encode(archive);

    // Save the zip file to temporary storage and then to external storage
    if (zipData != null) {
      await zipFile.writeAsBytes(zipData);
      debugPrint('Zip file created at: ${zipFile.path}');
	  await _saveFileToExternalStorage(zipFile);
    } else {
      debugPrint('Failed to create zip file');
    }
  }

  /// Saves the given [file] (zip archive) to external storage using a file dialog.
  ///
  /// The user is prompted to choose the location to save the file using [FlutterFileDialog].
  static Future<void> _saveFileToExternalStorage(File file) async {
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    if (filePath != null) {
      debugPrint('File saved to: $filePath');
    } else {
      debugPrint('Failed to save file');
    }
  }

  /// Fetches an image from the given [imageUrl] with retry logic.
  ///
  /// Attempts to download the image up to [retries] times (default is 3).
  /// Each attempt waits for 2 seconds before retrying if the download fails.
  /// Returns an [http.Response] object if successful, or null if all attempts fail.
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
