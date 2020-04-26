import 'package:flutter/material.dart';

import '../constants/database.dart';
import '../constants/strings_user_visible.dart';
import '../utils/date.dart';
import 'database_entry.dart';

class RssFeed extends DatabaseEntry {
  @override
  int id;
  String url;
  String name;
  int lastUpdate;

  String get formattedLastUpdate => lastUpdate != null ? lastUpdate.formattedDate() : kEntryListUpdatedNever;

  RssFeed({@required this.id, @required this.url, @required this.name, this.lastUpdate});

  RssFeed.fromMap(Map<String, dynamic> map) {
    id = map[kColumnId];
    url = map[kColumnUrl];
    name = map[kColumnName];
    lastUpdate = map[kColumnLastUpdate];
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

  RssFeed withUpdatedTime() {
    lastUpdate = DateTime.now().millisecondsSinceEpoch;
    return this;
  }
}
