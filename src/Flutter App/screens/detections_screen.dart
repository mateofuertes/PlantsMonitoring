import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/detections_widget.dart';
import 'package:app/Utils/date_utils.dart';

class DetectionsScreen extends StatefulWidget {
  const DetectionsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DetectionsScreenState createState() => _DetectionsScreenState();
}


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
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Date: ${MyDateUtils.formatDate(provider.selectedDay)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const DetectionsWidget(),
        ],
      ),
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
