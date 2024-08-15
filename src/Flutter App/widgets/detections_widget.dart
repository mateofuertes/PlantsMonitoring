import 'package:app/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/app_provider.dart';

class DetectionsWidget extends StatelessWidget {
  const DetectionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    String selectedDate = MyDateUtils.extractDate(provider.selectedDay.toIso8601String());
    List<String> imagesForSelectedDay = provider.imagesByDate[selectedDate] ?? [];

    return Expanded(
      child: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : imagesForSelectedDay.isEmpty
              ? const Center(
                  child: Text(
                    'No detections on this date',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                )
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
