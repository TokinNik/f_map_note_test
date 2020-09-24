part of 'map_bloc.dart';

@immutable
abstract class MapState {}

class MapInitialState extends MapState {}

class MarkerListShowedState extends MapState {}
class MarkerListHiddenState extends MapState {}

class MapMarkerLoadInProgressState extends MapState {}
class MapMarkerLoadSuccessState extends MapState {
  final List<MarkerData> markerDataList;

  MapMarkerLoadSuccessState(this.markerDataList);

  List<Object> get value => markerDataList;

  @override
  String toString() => 'MapMarkerLoadSuccess { markerData: $markerDataList }';
}
class MapMarkerLoadFail extends MapState {}
