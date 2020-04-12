import 'package:flutter/material.dart';

import '../constants/database.dart';
import '../utils/date.dart';
import 'database_entry.dart';

class RssFeed extends DatabaseEntry {
  int id;
  String url;
  String name;
  int lastUpdate;

  String get formattedLastUpdate => lastUpdate.formattedDate();

  RssFeed({@required this.id, @required this.url, @required this.name, this.lastUpdate});

  RssFeed.fromMap(Map<String, dynamic> map) {
    this.id = map[kColumnId];
    this.url = map[kColumnUrl];
    this.name = map[kColumnName];
    this.lastUpdate = map[kColumnLastUpdate];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      kColumnId: id,
      kColumnUrl: url,
      kColumnName: name,
      kColumnLastUpdate: lastUpdate,
    };
  }
}
