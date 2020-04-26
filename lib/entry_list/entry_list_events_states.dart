import 'package:flutter/cupertino.dart';

import '../types/rss_entry.dart';

abstract class EntryListEvent {}

class RequestEntryList extends EntryListEvent {
  final int feedId;

  RequestEntryList({@required this.feedId});
}

class UpdateEntryList extends EntryListEvent {
  final int feedId;

  UpdateEntryList({@required this.feedId});
}

abstract class EntryListState {}

class LoadingEntryList extends EntryListState {}

class EntryListLoaded extends EntryListState {
  final List<RssEntry> entryList;

  EntryListLoaded({@required this.entryList});
}

class EntryListFailed extends EntryListState {
  final String error;

  EntryListFailed({@required this.error});
}
