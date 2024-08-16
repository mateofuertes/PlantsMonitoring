import 'package:app/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/app_provider.dart';

/// [DetectionsWidget] is a stateless widget that displays detection images for a selected date.
/// Based on the current state of the [AppProvider] (loading, no detections, or detections available),
/// it displays a loading indicator, a message, or a grid of images.
class DetectionsWidget extends StatelessWidget {
  const DetectionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the AppProvider to get the current state of the app.
    final provider = Provider.of<AppProvider>(context);

    // Extract the selected date from the provider and format it as a string.
    String selectedDate = MyDateUtils.extractDate(provider.selectedDay.toIso8601String());

    // Get the list of images corresponding to the selected date. If no images are found,
    // return an empty list.
    List<String> imagesForSelectedDay = provider.imagesByDate[selectedDate] ?? [];

    // Build the UI based on the current state of the provider.
    return Expanded(
      child: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          // If there are no images for the selected date, display a message indicating no detections.
          : imagesForSelectedDay.isEmpty
              ? const Center(
                  child: Text(
                    'No detections on this date',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                )
              // If there are images, display them in a grid view.
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: imagesForSelectedDay.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imagesForSelectedDay[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
