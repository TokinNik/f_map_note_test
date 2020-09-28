import 'package:f_map_note_test/db/database.dart';
import 'package:f_map_note_test/utils/notification_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class MarkerListItem extends StatefulWidget {
  final MarkerData markerData;
  final Marker mapMarker;
  final Function(LatLng target) onTapGoTo;
  final Function(MarkerListItem item) onTapDelete;

  MarkerListItem(
      {this.markerData, this.onTapGoTo, this.onTapDelete, this.mapMarker});

  @override
  State<StatefulWidget> createState() => _MarkerListItemState();
}

class _MarkerListItemState extends State<MarkerListItem> {
  final DateFormat dateFormat = DateFormat("HH:mm - dd.MM.yyyy");

  bool bodyOffstage = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            bodyOffstage = !bodyOffstage;
          });
        },
        child: Container(
          //height: 50,
          margin: EdgeInsets.all(8),
          color: Colors.orange,
          child: Center(
              child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(widget.markerData.name),
                        Text(dateFormat.format(widget.markerData.time)),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 10,
                  ),
                  Column(
                    children: [
                      Offstage(
                        offstage: !widget.markerData.hasMarker,
                        child: FlatButton(
                            onPressed: () {
                              widget.onTapGoTo(widget.markerData.target);
                            },
                            padding: EdgeInsets.all(0.0),
                            child: Icon(Icons.my_location)),
                      ),
                    ],
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Column(
                    children: [
                      FlatButton(
                          onPressed: () {
                            NotificationManager.notificationManager
                                .cancelNotification(widget.markerData.id);
                            widget.onTapDelete(widget);
                          },
                          padding: EdgeInsets.all(0.0),
                          child: Icon(Icons.delete)),
                    ],
                  )
                ],
              ),
              Offstage(
                offstage: bodyOffstage,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          widget.markerData.description,
                          maxLines: 20,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
        ));
  }
}
