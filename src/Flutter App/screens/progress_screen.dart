import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/app_provider.dart';
import 'package:app/widgets/progress_widget.dart';
import 'package:app/widgets/download_dialog.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    try {
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
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : ProgressWidget(imagesByDate: provider.imagesByDate),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDownloadOptions(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.download, color: Colors.white),
      ),
    );
  }

  void _showDownloadOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DownloadDialog();
      },
    );
  }
}
