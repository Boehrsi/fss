import 'package:flutter/material.dart';

import '../constants/strings_user_visible.dart';

class RssList extends StatefulWidget {
  @override
  _RssListState createState() => _RssListState();
}

class _RssListState extends State<RssList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(screenRssListTitle)),
      body: ListView.builder(itemBuilder: (context, index) {
        return ListTile(
          title: Text("$index"), // TODO replace placeholder with actual logic
        );
      }),
    );
  }
}
