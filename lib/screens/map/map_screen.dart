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
                    setState(() {
                      _markers.add(
                          Marker(
                              markerId: MarkerId(target.toString()),
                              position: target,
                              infoWindow: InfoWindow(
                                title: "lat:${num.parse(target.latitude.toStringAsFixed(4))};lng:${num.parse(target.longitude.toStringAsFixed(4))}",
                              ),
                              icon: BitmapDescriptor.defaultMarker
                          )
                      );
                      markersItems.add(new MarkerListItem(
                        name: 'lat:${num.parse(target.latitude.toStringAsFixed(4))};lng:${num.parse(target.longitude.toStringAsFixed(4))}',
                        description: "descr",
                        target: target,
                        onTap: (target) {
                          setState(() {
                            markersOffstage = true;
                            _goToTheMarker(target);
                          });
                        },
                      ));
                    });
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