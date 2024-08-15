class MyDateUtils {
  static String formatDate(DateTime date) {
    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  static String extractDate(String fileName) {
    RegExp regex = RegExp(r'(\d{4}-\d{2}-\d{2})');
    Match? match = regex.firstMatch(fileName);
    if (match != null) {
      return match.group(0)!;
    }
    return 'Unknown date';
  }
}
