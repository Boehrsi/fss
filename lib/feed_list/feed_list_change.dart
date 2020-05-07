import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/dimensions.dart';
import '../constants/strings_user_visible.dart';
import '../feed_list/feed_list_barrel.dart';
import '../types/rss_feed.dart';

enum Type {
  add,
  edit,
  editId,
  delete,
}

enum _DialogResult {
  yes,
  no,
}

class FeedListChange extends StatefulWidget {
  final RssFeed feed;

  const FeedListChange({Key key, this.feed}) : super(key: key);

  @override
  _FeedListChangeState createState() => _FeedListChangeState();
}

class _FeedListChangeState extends State<FeedListChange> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isEditMode;

  @override
  void initState() {
    super.initState();
    final feed = widget.feed;
    _isEditMode = feed != null;
    if (_isEditMode) {
      _nameController.text = feed.name;
      _urlController.text = feed.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? kFeedChangeScreenTitleEdit : kFeedChangeScreenTitleAdd),
        actions: <Widget>[
          Visibility(
            visible: _isEditMode,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => showDeleteDialog(context),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: kDefault8dp, horizontal: kDefault16dp),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: kFeedChangeNameLabel),
                controller: _nameController,
                validator: (value) => value.isEmpty ? kFeedChangeNameErrorHint : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: kFeedChangeUrlLabel),
                controller: _urlController,
                validator: (value) => value.isEmpty ? kFeedChangeNameErrorHint : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kDefault16dp),
                child: Center(
                  child: RaisedButton(
                    child: Text(kFeedChangeSubmitButton),
                    onPressed: () => setFeed(context),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(kFeedChangeDeleteDialogTitle),
            content: Text('$kFeedChangeDeleteDialogText: ${widget.feed.name}?'),
            actions: <Widget>[
              FlatButton(child: Text(kNo), onPressed: () => Navigator.pop(context, _DialogResult.no)),
              FlatButton(
                child: Text(kYes),
                onPressed: () {
                  BlocProvider.of<FeedListBloc>(context).add(DeleteFeed(feed: widget?.feed));
                  Navigator.pop(context, _DialogResult.yes);
                },
              ),
            ],
          );
        }).then((result) {
      if (result == _DialogResult.yes) {
        Navigator.pop(context, Type.delete);
      }
    });
  }

  void setFeed(BuildContext context) {
    if (_formKey.currentState.validate()) {
      final newUrl = _urlController.text;
      final feed = RssFeed(
        id: newUrl.hashCode,
        url: newUrl,
        name: _nameController.text,
      );
      Type type;
      if (widget?.feed == null) {
        type = Type.add;
      } else if (widget.feed.url == newUrl) {
        type = Type.edit;
      } else {
        type = Type.editId;
      }
      BlocProvider.of<FeedListBloc>(context).add(SetFeed(newFeed: feed, oldFeed: widget?.feed));
      Navigator.pop(context, type);
    }
  }
}
