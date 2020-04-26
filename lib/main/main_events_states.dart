import 'package:flutter/widgets.dart';

abstract class MainEvent {}

class PrepareApp extends MainEvent {}

abstract class MainState {}

class LoadingApp extends MainState {}

class AppLoaded extends MainState {}

class AppFailed extends MainState {
  final String error;

  AppFailed({@required this.error});
}
