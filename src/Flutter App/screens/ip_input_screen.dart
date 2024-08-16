import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:app/providers/app_provider.dart';
import 'home_screen.dart';

/// [IpInputScreen] is a stateful widget that allows the user to input the server IP address.
/// It handles the connection process and navigates to the [HomeScreen] upon a successful connection.
class IpInputScreen extends StatefulWidget {
  const IpInputScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IpInputScreenState createState() => _IpInputScreenState();
}

/// The state for this widget
class _IpInputScreenState extends State<IpInputScreen> {
  // Controller to manage the text input for the IP address.
  final TextEditingController _ipController = TextEditingController();

  /// Checks the connection to the server using the entered IP address.
  /// If the connection is successful, it navigates to the [HomeScreen].
  Future<void> _checkConnection(String ip) async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    if (ip.isEmpty) {
      appProvider.setErrorMessage('Please enter the server IP.');
      return;
    }
    if (ip.split('.').length != 4) {
      appProvider.setErrorMessage('Invalid IP address.');
      return;
    }
    appProvider.setIsLoading(true);
    appProvider.setErrorMessage("Trying to connect to the server...");

    try {
      // Attempt to connect to the server by sending an HTTP GET request to the IP address.
      final response = await http.get(Uri.parse('http://$ip:5000/images')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        appProvider.setBaseUrl(ip);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        appProvider.setErrorMessage('Failed to connect to the server. Please check the IP and try again.');
      }
    } catch (e) {
      appProvider.setErrorMessage('Failed to connect to the server. Please check the IP and try again.');
    } finally {
      appProvider.setIsLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppProvider appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      // AppBar with the title of the app and a green background color.
      appBar: AppBar(
        title: const Text('Plants Monitoring'),
        backgroundColor: Colors.green,
      ),
      // Main content of the screen.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Server IP',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              keyboardType: TextInputType.number,
              cursorColor: Colors.green,
            ),
            const SizedBox(height: 16.0),
            // Show a loading indicator if the app is in a loading state.
            appProvider.isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
                // Show a button to attempt connection to the server.
                : ElevatedButton(
                    onPressed: () => _checkConnection(_ipController.text),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    child: const Text('Connect', style: TextStyle(color: Colors.white)),
                  ),
            // Display error messages if any.
            if (appProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  appProvider.errorMessage!,
                  style: const TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
