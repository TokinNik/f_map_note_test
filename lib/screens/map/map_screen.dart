import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> _markers = {};

  bool markersOffstage = true;

  static final CameraPosition _startPosition = CameraPosition(
    target: LatLng(59.945933, 30.320045),
    zoom: 10,
  );

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
                    });
                  }),
          Offstage(
            offstage: markersOffstage,
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  Container(
                    height: 30,
                    color: Colors.black12,
                    child: Center(
                      child: Text('123'),
                    ),
                  ),
                  Container(
                    height: 30,
                    color: Colors.black26,
                    child: Center(
                      child: Text('123'),
                    ),
                  ),
                  Container(
                    height: 30,
                    color: Colors.black38,
                    child: Center(
                      child: Text('123'),
                    ),
                  ),
                  Container(
                    height: 30,
                    color: Colors.black45,
                    child: Center(
                      child: Text('123'),
                    ),
                  ),
                  Container(
                    height: 30,
                    color: Colors.black54,
                    child: Center(
                      child: Text('123'),
                    ),
                  ),
                  Container(
                    height: 30,
                    color: Colors.black87,
                    child: Center(
                      child: Text('123'),
                    ),
                  ),
                  Container(
                    height: 30,
                    color: Colors.black12,
                    child: Center(
                      child: Text('123'),
                    ),
                  ),
                ],

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
        currentIndex: 0,
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