import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fss/types/rss_feed.dart';

import '../constants/strings_user_visible.dart';
import '../entry_list/entry_list.dart';
import '../feed_list/feed_list_barrel.dart';
import '../widgets/state_info.dart';
import 'feed_list_change.dart';

class FeedList extends StatefulWidget {
  @override
  _FeedListState createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  FeedListBloc _bloc;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<FeedListBloc>(context);
    _bloc.add(RequestFeedList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kFeedListScreenTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<String>(
                  builder: (context) {
                    return BlocProvider.value(
                      value: _bloc,
                      child: FeedListChange(),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
      body: BlocConsumer<FeedListBloc, FeedListState>(
        listener: (BuildContext context, state) {
          if (_refreshCompleter != null && !_refreshCompleter.isCompleted) {
            _refreshCompleter.complete();
          }
          if (state is FeedListUpdated && state.failedFeedNameList.isNotEmpty) {
            final snackBar = SnackBar(content: Text('$kErrorFeedUpdate: ${state.failedFeedNameList.join(', ')}'));
            Scaffold.of(context).showSnackBar(snackBar);
          }
        },
        builder: (BuildContext context, state) {
          if (state is FeedListLoaded || state is FeedListUpdated) {
            final feedList = state is FeedListLoaded ? state.feedList : state is FeedListUpdated ? state.feedList : null;
            return RefreshIndicator(
              onRefresh: () {
                _refreshCompleter = Completer();
                _bloc.add(UpdateFeedList());
                return _refreshCompleter.future;
              },
              child: ListView.builder(
                itemCount: feedList.length,
                itemBuilder: (context, index) {
                  var feed = feedList[index];
                  return FeedListItem(feed: feed, bloc: _bloc);
                },
              ),
            );
          } else if (state is FeedListFailed) {
            return ErrorState(error: state.error);
          } else {
            return LoadingState();
          }
        },
      ),
    );
  }
}

class FeedListItem extends StatelessWidget {
  const FeedListItem({Key key, @required RssFeed feed, @required FeedListBloc bloc})
      : _feed = feed,
        _bloc = bloc,
        super(key: key);

  final RssFeed _feed;
  final FeedListBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_feed.name),
      subtitle: Text('$kFeedListLastUpdate: ${_feed.formattedLastUpdate}'),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute<String>(
            builder: (context) {
              return BlocProvider.value(
                value: _bloc,
                child: EntryList(feedId: _feed.id),
              );
            },
          ),
        );
        if (result != null) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(result)));
        }
      },
    );
  }
}