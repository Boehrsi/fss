import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../constants/strings_user_visible.dart';
import '../database/database_wrapper.dart';
import '../feed_list/feed_list_events_states.dart';
import '../types/rss_entry.dart';
import '../types/rss_feed.dart';
import '../utils/rss.dart';

class FeedListBloc extends Bloc<FeedListEvent, FeedListState> with RssReader {
  final databaseWrapper = DatabaseWrapper();

  @override
  FeedListState get initialState => LoadingFeedList();

  @override
  Stream<FeedListState> mapEventToState(FeedListEvent event) async* {
    if (event is RequestFeedList) {
      yield* loadFeedList();
    } else if (event is UpdateFeedList) {
      yield* updateFeedList();
    } else if (event is SetFeed) {
      yield* setFeed(event);
    } else if (event is DeleteFeed) {
      yield* deleteFeed(event.feed);
    }
  }

  Stream<FeedListState> loadFeedList() async* {
    try {
      final feedList = await databaseWrapper.getAllFeedsAsync();
      yield FeedListLoaded(feedList: feedList);
    } catch (exception) {
      yield FeedListFailed(error: exception.toString());
    }
  }

  Stream<FeedListState> setFeed(SetFeed event) async* {
    final newFeed = event.newFeed;
    final oldFeed = event.oldFeed;
    if (oldFeed != null && newFeed.id != oldFeed.id) {
      await databaseWrapper.deleteAsync(oldFeed, RssFeed);
    } else if (oldFeed != null && newFeed.id == oldFeed.id) {
      newFeed.lastUpdate = oldFeed.lastUpdate;
    }
    await databaseWrapper.setAsync(newFeed, RssFeed);
    yield* loadFeedList();
  }

  Stream<FeedListState> deleteFeed(RssFeed feed) async* {
    await databaseWrapper.deleteAsync(feed, RssFeed);
    await databaseWrapper.clearStoreAsync(RssEntry, feed.id);
    yield* loadFeedList();
  }

  Stream<FeedListState> updateFeedList() async* {
    final feedList = await databaseWrapper.getAllFeedsAsync();
    final failedFeedNameList = <String>[];
    await Future.wait(feedList.map((feed) async {
      try {
        final response = await http.get(feed.url);
        if (response.statusCode == 200) {
          final entries = await getRssEntryList(response.bodyBytes);
          await databaseWrapper.setMultipleAsync(entries, RssEntry, feed.id);
          await databaseWrapper.setAsync(feed.withUpdatedTime(), RssFeed);
        } else {
          throw Exception(kErrorFeedLoading);
        }
      } catch (exception) {
        failedFeedNameList.add(feed.name);
      }
    }));
    yield FeedListUpdated(feedList: feedList, failedFeedNameList: failedFeedNameList);
  }
}
