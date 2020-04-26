import 'package:bloc/bloc.dart';

import '../database/database_wrapper.dart';
import 'main_events_states.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  @override
  MainState get initialState => LoadingApp();

  MainBloc() {
    add(PrepareApp());
  }

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    if (event is PrepareApp) {
      yield* _prepareApp();
    }
  }

  Stream<MainState> _prepareApp() async* {
    try {
      final databaseWrapper = DatabaseWrapper();
      await databaseWrapper.initAsync();
      yield AppLoaded();
    } catch (exception) {
      yield AppFailed(error: exception.toString());
    }
  }
}
