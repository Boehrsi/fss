import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'constants/strings_user_visible.dart';
import 'feed_list/feed_list.dart';
import 'feed_list/feed_list_barrel.dart';
import 'main/main_barrel.dart';
import 'widgets/state_info.dart';

void main() {
  runApp(FssApp());
}

class FssApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.redAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: BlocBuilder(
        bloc: MainBloc(),
        builder: (BuildContext context, state) {
          if (state is AppLoaded) {
            return BlocProvider(
              create: (BuildContext context) => FeedListBloc(),
              child: FeedList(),
            );
          } else if (state is AppFailed) {
            return ErrorState(error: state.error);
          } else {
            return LoadingState();
          }
        },
      ),
    );
  }
}
