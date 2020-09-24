import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:f_map_note_test/db/database.dart';
import 'package:meta/meta.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {

  MapBloc() : super(MapMarkerLoadInProgressState());

  bool markerListVisibility = false;
  List<MarkerData> markersData;

  @override
  Stream<MapState> mapEventToState(MapEvent event,) async* {
    if (event is MarkersLoadProcessedEvent) {
      yield* _mapMarkerLoadInProgressToState();
    } else if (event is MarkersLoadSuccessEvent) {
      yield* _mapMarkerLoadedToState();
    } else if (event is MarkerListShovedEvent) {
      yield* _mapMarkerListShowedToState();
    } else if (event is MarkerListHidedEvent) {
      yield* _mapMarkerListHidedToState();
    } else if (event is MarkerAddedEvent) {
      yield* _mapMarkerAddedToState(event);
    } else if (event is MarkerDeletedEvent) {
      yield* _mapMarkerDeletedToState(event);
    }
  }

  Stream<MapState> _mapMarkerLoadedToState() async*{
    yield MapMarkerLoadSuccessState(markersData);
  }

  Stream<MapState> _mapMarkerListShowedToState() async*{
    markerListVisibility = true;
    yield MapMarkerLoadSuccessState(markersData);
  }

  Stream<MapState> _mapMarkerListHidedToState() async*{
    markerListVisibility = false;
    yield MapMarkerLoadSuccessState(markersData);
  }

  Stream<MapState> _mapMarkerAddedToState(MarkerAddedEvent event) async*{
    if (state is MapMarkerLoadSuccessState) {
      await MarkersDB.db.insertMarker(event.markerData);
      try {
        markersData = await MarkersDB.db.getAllMarkers();
        yield MapMarkerLoadSuccessState(markersData);
      }
      catch (_) {
        yield MapMarkerLoadFail();
      }
    }
  }

  Stream<MapState> _mapMarkerDeletedToState(MarkerDeletedEvent event) async*{
    if (state is MapMarkerLoadSuccessState) {
      await MarkersDB.db.deleteMarker(event.markerId);
      try {
        markersData = await MarkersDB.db.getAllMarkers();
        yield MapMarkerLoadSuccessState(markersData);
      }
      catch (_) {
        yield MapMarkerLoadFail();
      }
    }
  }

  Stream<MapState> _mapMarkerLoadInProgressToState() async*{
    try {
      markersData = await MarkersDB.db.getAllMarkers();
      yield MapMarkerLoadSuccessState(markersData);
    }
    catch (_) {
      yield MapMarkerLoadFail();
    }
  }


  @override
  void onChange(Change<MapState> change) {
    print(change);
    super.onChange(change);
  }

  @override
  void onEvent(MapEvent event) {
    print(event);
    super.onEvent(event);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print(error);
    super.onError(error, stackTrace);
  }

  @override
  void onTransition(Transition<MapEvent, MapState> transition) {
    print(transition);
    super.onTransition(transition);
  }
}