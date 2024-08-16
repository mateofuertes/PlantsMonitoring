import 'package:app/utils/date_utils.dart';
import 'package:flutter/material.dart';

/// [ProgressWidget] is a stateless widget that displays a image taken daily.
class ProgressWidget extends StatelessWidget {
  final Map<String, List<String>> imagesByDate;

  const ProgressWidget({super.key, required this.imagesByDate});

  @override
  Widget build(BuildContext context) {
    List<String> progressImages = imagesByDate.entries
        .map((entry) {
          entry.value.sort((a, b) {
            final dateA = MyDateUtils.extractDate(a);
            final dateB = MyDateUtils.extractDate(b);
            return dateB.compareTo(dateA);
          });
          return entry.value.first;
        })
        .toList();

    progressImages.sort((a, b) {
      final dateA = MyDateUtils.extractDate(a);
      final dateB = MyDateUtils.extractDate(b);
      return dateB.compareTo(dateA);
    });

    // Build the UI based on the images.
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
        childAspectRatio: 1.05,
      ),
      itemCount: progressImages.length,
      itemBuilder: (context, index) {
        String imageUrl = progressImages[index];
        String fileName = imageUrl.split('/').last;
        String datePart = MyDateUtils.extractDate(fileName);
        DateTime date = DateTime.parse(datePart);

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                MyDateUtils.formatDate(date),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
