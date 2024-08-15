import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/download_service.dart';
import 'package:intl/intl.dart';

class DownloadDialog extends StatefulWidget {
  const DownloadDialog({super.key});

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  String _selectedOption = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final totalImages = provider.imagesByDate.values.expand((x) => x).length;

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

  void _downloadImages(BuildContext context, String option, DateTime? startDate, DateTime? endDate) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.setIsLoading(true);
    await DownloadService.downloadImages(provider.imagesByDate, option, startDate, endDate);
    provider.setIsLoading(false);
  }
}
