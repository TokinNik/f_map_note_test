import 'dart:async';

import 'package:f_map_note_test/db/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/scheduler.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
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
                          MarkersDB.db.deleteMarker(markerData.id);
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

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> _markers = {};
  List<MarkerListItem> markersItems = List<MarkerListItem>();

  bool markersOffstage = true;
  bool first = false;

  static final CameraPosition _startPosition = CameraPosition(
    target: LatLng(59.945933, 30.320045),
    zoom: 10,
  );

  Future<void> _goToTheMarker(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 10)));
  }

  void _showAddMarkerDialog(LatLng target) {
    String name = 'Marker';
    String description = 'description';

    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
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
                addMarker(markerData);
                MarkersDB.db.insertMarker(markerData);
                Navigator.of(context).pop();
                setState(() {});
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

  void addMarker(MarkerData markerData) {
    _markers.add(Marker(
        markerId: MarkerId(markerData.target.toString()),
        position: markerData.target,
        infoWindow: InfoWindow(title: markerData.name),
        icon: BitmapDescriptor.defaultMarker));
    markersItems.add(new MarkerListItem(
      mapMarker: _markers.last,
      markerData: markerData,
      onTapGoTo: (target) {
        setState(() {
          markersOffstage = true;
          _goToTheMarker(target);
        });
      },
      onTapDelete: (item) {
        markersItems.remove(item);
        _markers.remove(item.mapMarker);
        setState(() {});
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    //MarkersDB.db.deleteAll();
    //MarkersDB.db.insertMarker(MarkerData(name: "name", description: "description", target: _startPosition.target, time: "00"));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!first) {
        first = !first;
        setState(() {});
      }
    });

    return new Scaffold(
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
                print(
                    "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                _showAddMarkerDialog(target);
              }),
          Offstage(
              offstage: markersOffstage,
              child: FutureBuilder<List<MarkerData>>(
                future: MarkersDB.db.getAllMarkers(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<MarkerData>> snapshot) {
                  if (snapshot.hasData) {
                    if (markersItems.isEmpty) {
                      for (MarkerData item in snapshot.data) {
                        addMarker(item);
                      }
                    }

                    return Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: markersItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          return markersItems[index];
                        },
                        //children: markersItems.isEmpty ? [Container()] : markersItems,
                      ),
                    );
                  } else {
                    return Container(
                        color: Colors.white,
                        child: Center(child: CircularProgressIndicator()));
                  }
                },
              ))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: new Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(
              icon: new Icon(Icons.add_location), label: "Markers")
        ],
        currentIndex: markersOffstage ? 0 : 1,
        onTap: (int index) {
          setState(() {
            if (index == 0) {
              markersOffstage = true;
              //Navigator.of(context).pushReplacementNamed('/Markers');
            } else {
              markersOffstage = false;
            }
          });
        },
      ),
    );
  }
}
