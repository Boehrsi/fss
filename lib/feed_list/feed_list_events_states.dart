import 'package:flutter/cupertino.dart';

import '../types/rss_feed.dart';

abstract class FeedListEvent {}

class RequestFeedList extends FeedListEvent {}

class SetFeed extends FeedListEvent {
  final RssFeed newFeed;
  final RssFeed oldFeed;

  SetFeed({@required this.newFeed, this.oldFeed});
}

class UpdateFeedList extends FeedListEvent {}

class DeleteFeed extends FeedListEvent {
  final RssFeed feed;

  DeleteFeed({@required this.feed});
}

abstract class FeedListState {}

class LoadingFeedList extends FeedListState {}

class FeedListLoaded extends FeedListState {
  final List<RssFeed> feedList;

  FeedListLoaded({@required this.feedList});
}

class FeedListUpdated extends FeedListState {
  final List<RssFeed> feedList;
  final List<String> failedFeedNameList;

  FeedListUpdated({@required this.feedList, @required this.failedFeedNameList});
}

class FeedListFailed extends FeedListState {
  final String error;

  FeedListFailed({@required this.error});
}
