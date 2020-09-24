import 'package:f_map_note_test/blocs/map/map_bloc.dart';
import 'package:f_map_note_test/screens/map/map_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarkersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
      if (state is MapMarkerLoadInProgressState)
      {
        return Container(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()));
      } else if (state is MapMarkerLoadSuccessState)
     {
       final markersData = state.value;
       return Scaffold(
           body: Container(
             color: Colors.white,
             padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
             child: ListView.builder(
               padding: const EdgeInsets.all(8),
               itemCount: markersData.length,
               itemBuilder: (BuildContext context, int index) {
                 return MarkerListItem(
                   markerData: markersData[index],
                   onTapGoTo: (target) {},
                   onTapDelete: (item) {},
                 );
               },
               //children: markersItems.isEmpty ? [Container()] : markersItems,
             ),
           )
       );
     } else {
        return  Container(
            color: Colors.white);
      }
    });
  }
}
