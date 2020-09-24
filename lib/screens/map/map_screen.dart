import 'dart:async';

import 'package:f_map_note_test/blocs/map/map_bloc.dart';
import 'package:f_map_note_test/db/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/scheduler.dart';

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

  /*if (state is MapMarkerLoadInProgressState) {
  return Container(
  color: Colors.white,
  child: Center(child: CircularProgressIndicator()));
  } else if (state is MapMarkerLoadSuccessState) {
  final markersData = state.value;*/

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
                        child: Center(child: CircularProgressIndicator()))
                    : Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: markersData.length,
                          itemBuilder: (BuildContext context, int index) {
                            addMarker(markersData[index], mapBloc);
                            return markersItems.last;
                          },
                          //children: markersItems.isEmpty ? [Container()] : markersItems,
                        ),
                      ),
              ),
            ],
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
                //Navigator.of(context).pushReplacementNamed('/Markers');
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add new marker'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Marker name',
                  ),
                ),
                Spacer(flex: 1),
                TextField(
                  onChanged: (value) {
                    description = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Marker description',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Approve'),
              onPressed: () {
                MarkerData markerData = MarkerData(
                    id: target.toString(),
                    name: name,
                    description: description,
                    target: target,
                    time: "00");
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

  void addMarker(MarkerData markerData, MapBloc mapBloc) {
    Marker marker = Marker(
        markerId: MarkerId(markerData.target.toString()),
        position: markerData.target,
        infoWindow: InfoWindow(title: markerData.name),
        icon: BitmapDescriptor.defaultMarker);
    _markers.add(marker);
    markersItems.add(new MarkerListItem(
      mapMarker: marker,
      markerData: markerData,
      onTapGoTo: (target) {
        _goToTheMarker(target);
        mapBloc.add(MarkerListHidedEvent());
      },
      onTapDelete: (item) {
        _markers.remove(item.mapMarker);
        markersItems.remove(item);
        mapBloc.add(MarkerDeletedEvent(markerData.id));
      },
    ));
  }
}

class MarkerListItem extends StatelessWidget {
  final MarkerData markerData;
  final Marker mapMarker;
  final Function(LatLng target) onTapGoTo;
  final Function(MarkerListItem item) onTapDelete;
  MaterialColor bgColor = Colors.orange;

  MarkerListItem(
      {this.markerData, this.onTapGoTo, this.onTapDelete, this.mapMarker});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTapGoTo(markerData.target);
        },
        child: Container(
          height: 50,
          margin: EdgeInsets.all(8),
          color: bgColor,
          child: Center(
            child: Row(
              children: [
                Column(
                  children: [
                    Text(markerData.name),
                    Text(markerData.description),
                  ],
                ),
                Column(
                  children: [
                    FlatButton(
                        onPressed: () {
                          bgColor = Colors.deepOrange;
                          onTapDelete(this);
                        },
                        padding: EdgeInsets.all(0.0),
                        child: Icon(Icons.delete)),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
