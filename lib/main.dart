import 'package:flutter/material.dart';

import 'constants/strings_user_visible.dart';
import 'rss_list/rss_list.dart';

void main() {
  runApp(FssApp());
}

class FssApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.redAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RssList(),
    );
  }
}
