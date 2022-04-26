import 'package:flutter/material.dart';

import 'screens/home.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLDC Simulator',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MyHomePage(
        title: "MLDC Simulator",
      ),
    );
  }
}
