import 'dart:async';

enum PossibleStates { loading, loaded, noconnection }

class StateManagementBloc {
  final StreamController<PossibleStates> _streamController =
      StreamController<PossibleStates>.broadcast();

  Stream<PossibleStates> get possible_states_stream => _streamController.stream;

  void dispose() {
//    print('Disposed');
    _streamController.close();
  }

  void setPossibleState(PossibleStates state) => _streamController.add(state);
}
