import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MarkersScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MarkersScreenState();
}

class _MarkersScreenState extends State<MarkersScreen> {



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: ListView(
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
          currentIndex: 1,
          onTap: (int index){
            if(index == 0) {
              Navigator.of(context).pushReplacementNamed('/Map');
            }
          }),
    );
  }
}