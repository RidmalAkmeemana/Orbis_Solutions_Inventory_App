import 'package:flutter/material.dart';
import 'Screens/SplashScreen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      navigatorObservers: [
        routeObserver,
      ],
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SplashScreen(), // Load Splash Screen First
    );
  }
}
