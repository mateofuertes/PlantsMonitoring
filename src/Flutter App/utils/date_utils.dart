/// [MyDateUtils] is a utility class that provides static methods for handling
/// and formatting dates.
class MyDateUtils {
  
  /// Formats a given [DateTime] object into a readable string.
  ///
  /// If the given [date] corresponds to today's date, it returns 'Today'.
  /// Otherwise, it returns the date in 'day/month/year' format.
  static String formatDate(DateTime date) {
    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Extracts a date from a given [fileName] string using a regular expression.
  ///
  /// The method searches the [fileName] for a date in the format 'yyyy-mm-dd'.
  /// If a date is found, it returns the matched date string.
  /// If no date is found, it returns 'Unknown date'.
  static String extractDate(String fileName) {
    RegExp regex = RegExp(r'(\d{4}-\d{2}-\d{2})');
    Match? match = regex.firstMatch(fileName);
    if (match != null) {
      return match.group(0)!;
    }
    return 'Unknown date';
  }
}
