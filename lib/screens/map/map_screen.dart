import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class MarkerListItem extends StatelessWidget {
  final LatLng target;
  final String name;
  final String description;
  final Function(LatLng target) onTap;

  MarkerListItem({this.name, this.description, this.target, this.onTap});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () {
        onTap(target);
      },
        child: Container(
        height: 40,
        margin: EdgeInsets.all(8),
        color: Colors.orange,
        child: Center(
          child: Column(
           children: [
             Text(name),
             Text(description),
           ],
         ),
        ),
      )
    );
  }
}

class _MapScreenState extends State<MapScreen> {

  Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> _markers = {};
  List<MarkerListItem> markersItems = List<MarkerListItem>();

  bool markersOffstage = true;

  static final CameraPosition _startPosition = CameraPosition(
    target: LatLng(59.945933, 30.320045),
    zoom: 10,
  );

  Future<void> _goToTheMarker(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 10)));
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
                Spacer(),
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
                addMarker(target, name, description);
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

  void addMarker(LatLng target, String name, String description) {
    setState(() {
      _markers.add(
          Marker(
              markerId: MarkerId(target.toString()),
              position: target,
              infoWindow: InfoWindow(
                title: name
              ),
              icon: BitmapDescriptor.defaultMarker
          )
      );
      markersItems.add(new MarkerListItem(
        name: name,
        description: description,
        target: target,
        onTap: (target) {
          setState(() {
            markersOffstage = true;
            _goToTheMarker(target);
          });
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    _showAddMarkerDialog(target);
                  }),
          Offstage(
            offstage: markersOffstage,
            child: Container(
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
            )
          )
        ],
      ),
    bottomNavigationBar: BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
          icon: new Icon(Icons.map_outlined),
          label: "Map"
      ),
      BottomNavigationBarItem(
          icon: new Icon(Icons.add_location),
          label: "Markers"
      )
    ],
        currentIndex: markersOffstage ? 0 : 1,
        onTap: (int index){
      setState(() {
        if(index == 0) {
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