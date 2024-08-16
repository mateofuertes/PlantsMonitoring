import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/download_service.dart';
import 'package:intl/intl.dart';

/// [DownloadDialog] is a stateful widget that provides a user interface for
/// selecting download options for images. The user can choose to download all images
/// or images within a specific date range. The widget also handles date picking and
/// initiates the download process.
class DownloadDialog extends StatefulWidget {
  const DownloadDialog({super.key});

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  // Variable to track the selected download option ("all" or "range").
  String _selectedOption = 'all';

  // Variables to store the selected start and end dates for the date range option.
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    // Access the AppProvider to get image data and the current app state.
    final provider = Provider.of<AppProvider>(context);

    // Calculate the total number of images across all dates.
    final totalImages = provider.imagesByDate.values.expand((x) => x).length;

    // Build the AlertDialog that allows the user to choose download options.
    return AlertDialog(
      title: const Text('Download Images'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile(
            title: Text('All images ($totalImages)'),
            value: 'all',
            fillColor: MaterialStateProperty.all(Colors.green),
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
          RadioListTile(
            title: const Text('Images in date range'),
            value: 'range',
            fillColor: MaterialStateProperty.all(Colors.green),
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
          // Show date pickers for the date range if "range" is selected.
          if (_selectedOption == 'range')
            Column(
              children: [
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(primary: Colors.black),
                            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: Text(_startDate == null
                      ? 'Select start date'
                      : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}', style: const TextStyle(color: Colors.black54)),
                ),
                TextButton(
                  onPressed: () async {
                    // Open a date picker dialog and let the user pick an end date.
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(primary: Colors.black),
                            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                  child: Text(_endDate == null
                      ? 'Select end date'
                      : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}', style: const TextStyle(color: Colors.black54)),
                ),
              ],
            ),
        ],
      ),
      actions: <Widget>[
        // Button to trigger the download based on the selected option and dates.
        TextButton(
          child: const Text('Download', style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(context).pop();
            _downloadImages(context, _selectedOption, _startDate, _endDate);
          },
        ),
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      backgroundColor: Colors.white,
      iconColor: Colors.green,
      shadowColor: Colors.green,
    );
  }

  /// Method to handle the downloading of images based on the user's selection.
  /// 
  /// [option] can be either "all" to download all images or "range" to download images within
  /// a specific date range. [startDate] and [endDate] are only relevant if "range" is selected.
  void _downloadImages(BuildContext context, String option, DateTime? startDate, DateTime? endDate) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.setIsLoading(true);
    await DownloadService.downloadImages(provider.imagesByDate, option, startDate, endDate);
    provider.setIsLoading(false);
  }
}
