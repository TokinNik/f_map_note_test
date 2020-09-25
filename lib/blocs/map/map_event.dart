part of 'map_bloc.dart';

@immutable
abstract class MapEvent {}

class MarkerAddedEvent extends MapEvent {
  final MarkerData markerData;

  MarkerAddedEvent(this.markerData);

  MarkerData get value => markerData;

  @override
  String toString() => 'MarkerAdded { markerData: $markerData }';
}

class MarkerDeletedEvent extends MapEvent {
  final int markerId;

  MarkerDeletedEvent(this.markerId);

  int get value => markerId;

  @override
  String toString() => 'MarkerDeleted { markerId: $markerId }';
}

class MarkersLoadProcessedEvent extends MapEvent {}
class MarkersLoadSuccessEvent extends MapEvent {}

class MarkerListShovedEvent extends MapEvent {}
class MarkerListHidedEvent extends MapEvent {}