import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Note Test',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  static final CameraPosition _startPosition = CameraPosition(
    target: LatLng(59.945933, 30.320045),
    zoom: 10,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
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
                        title: "lat:${target.latitude};lng:${target.longitude}",
                    ),
                    icon: BitmapDescriptor.defaultMarker
                )
            );
          });
        }),

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
        ]),
    );
  }
}