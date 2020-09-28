import 'dart:async';

import 'package:f_map_note_test/blocs/map/map_bloc.dart';
import 'package:f_map_note_test/db/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'marker_list_item.dart';

class MapScreen extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> _markers = {};
  List<MarkerListItem> markersItems = List<MarkerListItem>();

  bool markersOffstage = true;
  bool first = false;

  static final CameraPosition _startPosition = CameraPosition(
    target: LatLng(59.945933, 30.320045),
    zoom: 10,
  );

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);
    List<MarkerData> markersData;
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MapMarkerLoadSuccessState) {
          markersData = state.value;
        }
      },
      builder: (context, state) {
        if (state is MapMarkerLoadSuccessState) {
          markersData = state.value;
        }

        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _startPosition,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onTap: (LatLng target) {
                    _showAddMarkerDialog(target, context, mapBloc);
                  }),
              Offstage(
                offstage: !mapBloc.markerListVisibility,
                child: markersData == null
                    ? Container(
                        color: Colors.white,
                        child: Center(child: Text("No one Marker here")))
                    : Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: markersData.length,
                          itemBuilder: (BuildContext context, int index) {
                            _addMarker(markersData[index], mapBloc);
                            return markersItems.last;
                          },
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: Offstage(
            offstage: !mapBloc.markerListVisibility,
            child: FloatingActionButton(
              onPressed: () {
                _showAddMarkerDialog(null, context, mapBloc);
              },
              child: Icon(Icons.add),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: new Icon(Icons.map_outlined), label: "Map"),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.add_location), label: "Markers")
            ],
            currentIndex: mapBloc.markerListVisibility ? 1 : 0,
            onTap: (int index) {
              if (index == 0) {
                mapBloc.add(MarkerListHidedEvent());
              } else {
                mapBloc.add(MarkerListShovedEvent());
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _goToTheMarker(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 10)));
  }

  void _showAddMarkerDialog(
      LatLng target, BuildContext context, MapBloc mapBloc) {
    String name = 'Marker';
    String description = 'description';
    DateTime time = DateTime.now().add(Duration(hours: 1));
    DateFormat dateFormat = DateFormat("HH:mm - dd.MM.yyyy");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add new marker'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: TextField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                        ],
                        onChanged: (value) {
                          name = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Marker name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: TextField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(300),
                        ],
                        onChanged: (value) {
                          description = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Marker description',
                        ),
                      ),
                    ),
                    Text('Alarm time: ${dateFormat.format(time)}'),
                    FlatButton(
                      onPressed: () {
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          onConfirm: (date) {
                            setState(() {
                              time = date;
                            });
                          },
                          currentTime: DateTime.now().add(Duration(hours: 1)),
                        );
                      },
                      child: Text("Set Time"),
                    )
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Approve'),
              onPressed: () {
                MarkerData markerData = MarkerData(
                    name: name,
                    description: description,
                    hasMarker: target != null,
                    target: target,
                    time: time);
                _markers.add(Marker(
                    markerId: MarkerId(markerData.target.toString()),
                    position: markerData.target,
                    infoWindow: InfoWindow(title: markerData.name),
                    icon: BitmapDescriptor.defaultMarker));
                mapBloc.add(MarkerAddedEvent(markerData));
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Marker _addMapMarker(MarkerData markerData, MapBloc mapBloc) {
    Marker marker = Marker(
        markerId: MarkerId(markerData.target.toString()),
        position: markerData.target,
        infoWindow: InfoWindow(title: markerData.name),
        icon: BitmapDescriptor.defaultMarker);
    _markers.add(marker);
    return marker;
  }

  void _addMarker(MarkerData markerData, MapBloc mapBloc) {
    markersItems.add(new MarkerListItem(
      mapMarker:
          markerData.hasMarker ? _addMapMarker(markerData, mapBloc) : null,
      markerData: markerData,
      onTapGoTo: (target) {
        if (markerData.target != null) {
          _goToTheMarker(target);
          mapBloc.add(MarkerListHidedEvent());
        }
      },
      onTapDelete: (item) {
        _markers.remove(item.mapMarker);
        markersItems.remove(item);
        mapBloc.add(MarkerDeletedEvent(markerData.id));
      },
    ));
  }
}
