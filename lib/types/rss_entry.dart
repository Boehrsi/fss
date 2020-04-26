import 'package:flutter/material.dart';

import '../constants/database.dart';
import '../utils/date.dart';
import 'database_entry.dart';

class RssEntry extends DatabaseEntry {
  @override
  int id;
  String url;
  String title;
  int date;
  String text;

  String get formattedDate => date.formattedDate();

  RssEntry({@required this.id, @required this.url, @required this.title, @required this.date, @required this.text});

  RssEntry.fromMap(Map<String, dynamic> map) {
    id = map[kColumnId];
    url = map[kColumnUrl];
    title = map[kColumnTitle];
    date = map[kColumnDate];
    text = map[kColumnText];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      kColumnId: id,
      kColumnUrl: url,
      kColumnTitle: title,
      kColumnDate: date,
      kColumnText: text,
    };
  }
}
