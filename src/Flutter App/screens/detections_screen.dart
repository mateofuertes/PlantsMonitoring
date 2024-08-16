import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/detections_widget.dart';
import 'package:app/Utils/date_utils.dart';

/// [DetectionsScreen] is a stateful widget that displays detections on a specific date.
/// It uses [AppProvider] to fetch and display images, and the date utilities from [MyDateUtils].
class DetectionsScreen extends StatefulWidget {
  const DetectionsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DetectionsScreenState createState() => _DetectionsScreenState();
}

// The state for this widget
class _DetectionsScreenState extends State<DetectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.fetchImages();
    });
  }
  @override
  Widget build(BuildContext context) {
    // Access the provider that holds the state of the application
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Displays the selected date using a formatted string
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Date: ${MyDateUtils.formatDate(provider.selectedDay)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Displays the detections using the DetectionsWidget
          const DetectionsWidget(),
        ],
      ),
      // A floating action button to refresh the detections by fetching the images again
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<AppProvider>(context, listen: false).fetchImages();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
