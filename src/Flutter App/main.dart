import 'package:app/screens/ip_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/app_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

/// The main entry point of the Flutter application ensures that Flutter bindings
/// are initialized, initializes the FlutterDownloader plugin, and starts the app
/// by running [MyApp].
void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: false
  );
  runApp(const MyApp());
}

/// [MyApp] is the root widget of the application.
///
/// It wraps the entire app in a [ChangeNotifierProvider] that provides the [AppProvider]
/// to the widget tree.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Plants Monitoring',  
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const IpInputScreen(), // The first screen displayed when the app starts.
      ),
    );
  }
}
