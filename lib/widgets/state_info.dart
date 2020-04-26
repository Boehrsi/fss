import 'package:flutter/material.dart';

import '../constants/dimensions.dart';
import '../constants/strings_user_visible.dart';

class LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String error;

  const ErrorState({Key key, @required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kDefault8dp),
        child: Text(
          '$kError: $error',
          style: Theme.of(context).textTheme.bodyText1.apply(color: Colors.red),
        ),
      ),
    );
  }
}
