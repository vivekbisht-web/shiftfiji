import 'package:flutter/material.dart';
import 'package:shiftfiji/screens/web_view.dart';

void main() {
  runApp(const ShiftFiji());
}

class ShiftFiji extends StatelessWidget {
  const ShiftFiji({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShiftFiji',
      debugShowCheckedModeBanner: false,
      home: const WebViewScreen(),
    );
  }

}