import 'package:flutter/material.dart';
import 'package:app/services/image_service.dart';
import 'package:app/services/date_service.dart';

class AppProvider with ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isLoading = false;
  Map<String, List<String>> _imagesByDate = {};
  String? _errorMessage;
  String? _baseUrl;
  int selectedScreen = 1;

  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  bool get isLoading => _isLoading;
  Map<String, List<String>> get imagesByDate => _imagesByDate;
  String? get errorMessage => _errorMessage;
  String? get baseUrl => _baseUrl;
  int get getSelectedScreen => selectedScreen;

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

  Future<void> fetchImages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _imagesByDate = await ImageService.fetch(_baseUrl!);
    } catch (error) {
      _imagesByDate = {};
      _errorMessage = 'Failed to load images';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await DateService.sendDate(_baseUrl!);
      debugPrint(response);
    } catch (error) {
      _errorMessage = 'Failed to set the actual date';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
