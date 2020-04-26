import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/strings_user_visible.dart';
import '../database/database_wrapper.dart';
import '../feed_list/feed_list_barrel.dart';
import '../types/rss_entry.dart';
import '../utils/rss.dart';
import 'entry_list_events_states.dart';

class EntryListBloc extends Bloc<EntryListEvent, EntryListState> with RssReader {
  final databaseWrapper = DatabaseWrapper();
  final FeedListBloc feedListBloc;

  EntryListBloc({@required this.feedListBloc});

  @override
  EntryListState get initialState => LoadingEntryList();

  @override
  Stream<EntryListState> mapEventToState(EntryListEvent event) async* {
    if (event is RequestEntryList) {
      yield* loadEntryList(event.feedId);
    } else if (event is UpdateEntryList) {
      yield* updateEntryList(event.feedId);
    }
  }

  Stream<EntryListState> loadEntryList(int feedId) async* {
    try {
      final entryList = await databaseWrapper.getAllEntriesAsync(feedId);
      yield EntryListLoaded(entryList: entryList.reversed.toList());
    } catch (exception) {
      yield EntryListFailed(error: exception.toString());
    }
  }

  Stream<EntryListState> updateEntryList(int feedId) async* {
    try {
      final feed = await databaseWrapper.getFeedAsync(feedId);
      final response = await http.get(feed.url);
      if (response.statusCode == 200) {
        final entries = await getRssEntryList(response.bodyBytes);
        await databaseWrapper.setMultipleAsync(entries, RssEntry, feedId);
        feedListBloc.add(SetFeed(newFeed: feed.withUpdatedTime()));
        yield* loadEntryList(feedId);
      } else {
        throw Exception(kErrorFeedLoading);
      }
    } catch (exception) {
      yield EntryListFailed(error: exception.toString());
    }
  }
}
