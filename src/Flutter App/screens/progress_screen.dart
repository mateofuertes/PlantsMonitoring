import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/app_provider.dart';
import 'package:app/widgets/progress_widget.dart';
import 'package:app/widgets/download_dialog.dart';

/// [ProgressScreen] is a stateful widget that displays a screen showing daily images and
/// provides a button to download the images.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProgressScreenState createState() => _ProgressScreenState();
}

 // The state for this widget
class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    try {
    // Fetch images from the server after the widget's build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.fetchImages();
    });
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the AppProvider to get the current state of the app.
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      // Main body of the screen, displaying either a loading indicator or progress data.
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : ProgressWidget(imagesByDate: provider.imagesByDate),
      // Floating action button to open the download options dialog.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDownloadOptions(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.download, color: Colors.white),
      ),
    );
  }

  /// Shows the download options dialog to allow the user to download images.
  void _showDownloadOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DownloadDialog();
      },
    );
  }
}
