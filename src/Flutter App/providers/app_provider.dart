import 'package:flutter/material.dart';
import 'package:app/services/image_service.dart';
import 'package:app/services/date_service.dart';

/// [AppProvider] is a ChangeNotifier class responsible for managing the application's state and logic.
/// It handles interactions across different screens, such as managing selected dates,
/// error messages, loading statuses, and fetching images from a remote source.
///
/// This provider is designed to centralize the state management for the app, allowing
/// multiple screens or widgets to listen for changes and update accordingly.
class AppProvider with ChangeNotifier {
  
  /// The date selected by the user in the calendar screen.
  DateTime _selectedDay = DateTime.now();

  /// The currently highlighted date in the calendar, which is typically today.
  DateTime _focusedDay = DateTime.now();

  /// A boolean flag to indicate whether the app is currently loading data (e.g., fetching images).
  bool _isLoading = false;

  /// A map that stores images categorized by date.
  /// The key is a date string, and the value is a list of image URLs. 
  Map<String, List<String>> _imagesByDate = {};

  /// An error message to indicate issues during data fetching or processing.
  String? _errorMessage;

  /// The base URL of the server that the app communicates with.
  String? _baseUrl;

  /// An integer to track which screen is currently selected in the app.
  int selectedScreen = 1;

  /// ---- Getters ----
  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  bool get isLoading => _isLoading;
  Map<String, List<String>> get imagesByDate => _imagesByDate;
  String? get errorMessage => _errorMessage;
  String? get baseUrl => _baseUrl;
  int get getSelectedScreen => selectedScreen;

  /// ---- Setters (Include notify listeners of the change). ----
  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  void setSelectedScreen(int screen) {
    selectedScreen = screen;
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void setImagesByDate(Map<String, List<String>> imagesByDate) {
    _imagesByDate = imagesByDate;
    notifyListeners();
  }

  void setErrorMessage(String? errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  void setBaseUrl(String ip) {
    _baseUrl = 'http://$ip:5000';
    notifyListeners();
  }

  /// Asynchronously fetches images from the server.
  /// Sets the loading state to true while the request is in progress and handles errors if the request fails.
  /// Once the images are fetched successfully, they are stored in [_imagesByDate].
  Future<void> fetchImages() async {
    setIsLoading(true);
    setErrorMessage(null);
    try {
      _imagesByDate = await ImageService.fetch(_baseUrl!);
    } catch (error) {
      setImagesByDate({});
      setErrorMessage('Failed to load images');
    } finally {
      setIsLoading(false);
    }
  }

  /// Asynchronously sends the current date to the server.
  /// Sets the loading state to true while the request is in progress and handles any errors during the request.
  Future<void> setDate() async {
    setIsLoading(true);
    setErrorMessage(null);
    try {
      final response = await DateService.sendDate(_baseUrl!);
    } catch (error) {
      setErrorMessage('Failed to set the actual date');
    } finally {
      setIsLoading(false);
    }
  }

}
