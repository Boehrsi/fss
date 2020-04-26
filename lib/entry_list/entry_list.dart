import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fss/types/rss_entry.dart';
import 'package:fss/types/rss_feed.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/dimensions.dart';
import '../constants/strings_user_visible.dart';
import '../feed_list/feed_list_barrel.dart';
import '../feed_list/feed_list_change.dart';
import '../widgets/state_info.dart';
import 'entry_list_barrel.dart';

class EntryList extends StatefulWidget {
  final int feedId;

  const EntryList({Key key, @required this.feedId}) : super(key: key);

  @override
  _EntryListState createState() => _EntryListState();
}

class _EntryListState extends State<EntryList> {
  EntryListBloc _bloc;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _bloc = EntryListBloc(feedListBloc: BlocProvider.of<FeedListBloc>(context));
    _bloc.add(RequestEntryList(feedId: widget.feedId));
  }

  @override
  Widget build(BuildContext context) {
    final parentContext = context;
    return BlocBuilder<FeedListBloc, FeedListState>(builder: (BuildContext context, state) {
      if (state is FeedListLoaded || state is FeedListUpdated) {
        final feed = _getFeed(state);
        if (feed != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(feed.name),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute<String>(
                        builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: BlocProvider.of<FeedListBloc>(parentContext)),
                              BlocProvider.value(value: _bloc),
                            ],
                            child: FeedListChange(feed: feed),
                          );
                        },
                      ),
                    );
                    if (result != null) {
                      Navigator.pop(context, result);
                    }
                  },
                )
              ],
            ),
            body: BlocConsumer(
              bloc: _bloc,
              listener: (BuildContext context, state) {
                if (_refreshCompleter != null && !_refreshCompleter.isCompleted) {
                  _refreshCompleter.complete();
                }
              },
              builder: (BuildContext context, state) {
                if (state is EntryListLoaded) {
                  return RefreshIndicator(
                    onRefresh: () {
                      _refreshCompleter = Completer();
                      _bloc.add(UpdateEntryList(feedId: widget.feedId));
                      return _refreshCompleter.future;
                    },
                    child: ListView.builder(
                        itemCount: state.entryList.length,
                        itemBuilder: (context, index) {
                          final entry = state.entryList[index];
                          return EntryListItem(entry: entry);
                        }),
                  );
                } else if (state is EntryListFailed) {
                  return ErrorState(error: state.error);
                } else {
                  return LoadingState();
                }
              },
            ),
          );
        } else {
          return Container();
        }
      } else {
        return ErrorState(error: kErrorFeedLoading);
      }
    });
  }

  RssFeed _getFeed(FeedListState state) {
    final feedList = state is FeedListLoaded ? state.feedList : state is FeedListUpdated ? state.feedList : null;
    return feedList.firstWhere((feed) => feed.id == widget.feedId, orElse: () => null);
  }
}

class EntryListItem extends StatelessWidget {
  const EntryListItem({Key key, @required this.entry}) : super(key: key);

  final RssEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(bottom: kDefault8dp),
          child: Text(entry.title, style: Theme.of(context).textTheme.headline6),
        ),
        subtitle: Html(
          data: entry.text,
          onLinkTap: (url) => launch(url),
        ),
        onTap: () => launch(entry.url),
      ),
    );
  }
}
