import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:webfeed/webfeed.dart' as webfeed;

import '../constants/strings_user_visible.dart';
import '../types/rss_entry.dart';

final _formatRss = DateFormat('EEE, d MMM yyyy HH:mm:ss Z');
final _typeRss = '<rss version="2.0"';

mixin RssReader {
  Future<List<RssEntry>> getRssEntryList(Uint8List xmlBytes) async {
    final xmlString = utf8.decode(xmlBytes);
    return await compute(_parseFeed, xmlString);
  }
}

List<RssEntry> _parseFeed(String responseBody) {
  final entries = <RssEntry>[];
  var parsedFeed;
  if (responseBody.contains(_typeRss)) {
    try {
      parsedFeed = webfeed.RssFeed.parse(responseBody);
    } catch (_) {}
  } else {
    try {
      parsedFeed ??= webfeed.AtomFeed.parse(responseBody);
    } catch (_) {}
  }
  if (parsedFeed == null) {
    throw Exception(kErrorFeedParse);
  }
  parsedFeed.items.forEach((item) {
    String url;
    DateTime date;
    String content;
    if (item is webfeed.RssItem) {
      url = item.link;
      date = _formatRss.parse(item.pubDate);
      content = item.description;
    } else if (item is webfeed.AtomItem) {
      url = item.links.first.href;
      date = DateTime.parse(item.published);
      content = item.content ?? item.summary;
    }

    entries.add(
      RssEntry(
        id: url.hashCode,
        url: url,
        title: item.title,
        date: date.millisecondsSinceEpoch,
        text: content,
      ),
    );
  });
  return entries;
}
