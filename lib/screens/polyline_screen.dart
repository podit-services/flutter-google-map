import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_polyline_points/google_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goolge_map_demo/enum/commute_mode.dart';

class PolylineScreen extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;

  const PolylineScreen({
    Key? key,
    required this.origin,
    required this.destination,
  }) : super(key: key);

  @override
  PolylineScreenState createState() => PolylineScreenState();
}

class PolylineScreenState extends State<PolylineScreen> {
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = dotenv.env['GOOGLE_MAP_API_KEY']!;
  CommuteMode commuteMode = CommuteMode.driving;

  @override
  void initState() {
    super.initState();
    log("Origin: ${widget.origin.toString()}");
    log("Destination: ${widget.destination.toString()}");

    /// origin marker
    _addMarker(
      widget.origin,
      "origin",
      BitmapDescriptor.defaultMarker,
    );

    /// destination marker
    _addMarker(
      widget.destination,
      "destination",
      BitmapDescriptor.defaultMarkerWithHue(90),
    );
    _getPolyline(
      origin: widget.origin,
      destination: widget.destination,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Polyline"),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.origin,
              zoom: 10,
            ),
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Card(
                    color: commuteMode == CommuteMode.driving
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    child: IconButton(
                      onPressed: () {
                        polylineCoordinates.clear();
                        setState(() {
                          commuteMode = CommuteMode.driving;
                          _getPolyline(
                            origin: widget.origin,
                            destination: widget.destination,
                          );
                        });
                      },
                      color: commuteMode == CommuteMode.driving
                          ? Colors.white
                          : Colors.grey.shade900,
                      icon: const Icon(FontAwesomeIcons.car),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: commuteMode == CommuteMode.bicycling
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    child: IconButton(
                      onPressed: () {
                        polylineCoordinates.clear();
                        setState(() {
                          commuteMode = CommuteMode.bicycling;
                          _getPolyline(
                            origin: widget.origin,
                            destination: widget.destination,
                          );
                        });
                      },
                      color: commuteMode == CommuteMode.bicycling
                          ? Colors.white
                          : Colors.grey.shade900,
                      icon: const Icon(FontAwesomeIcons.motorcycle),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: commuteMode == CommuteMode.transit
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    child: IconButton(
                      onPressed: () {
                        polylineCoordinates.clear();
                        setState(() {
                          commuteMode = CommuteMode.transit;
                          _getPolyline(
                            origin: widget.origin,
                            destination: widget.destination,
                          );
                        });
                      },
                      color: commuteMode == CommuteMode.transit
                          ? Colors.white
                          : Colors.grey.shade900,
                      icon: const Icon(FontAwesomeIcons.bus),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: commuteMode == CommuteMode.walking
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    child: IconButton(
                      onPressed: () {
                        polylineCoordinates.clear();
                        setState(() {
                          commuteMode = CommuteMode.walking;
                          _getPolyline(
                            origin: widget.origin,
                            destination: widget.destination,
                          );
                        });
                      },
                      color: commuteMode == CommuteMode.walking
                          ? Colors.white
                          : Colors.grey.shade900,
                      icon: const Icon(FontAwesomeIcons.personWalking),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 2,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  getTradeMode(CommuteMode commuteMode) {
    switch (commuteMode) {
      case CommuteMode.driving:
      case CommuteMode.bicycling:
        return TravelMode.driving;
      case CommuteMode.transit:
        return TravelMode.transit;
      case CommuteMode.walking:
        return TravelMode.walking;
      default:
        return TravelMode.driving;
    }
  }

  _getPolyline({required LatLng origin, required LatLng destination}) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      LatLngCoordinate(origin.latitude, origin.longitude),
      LatLngCoordinate(destination.latitude, destination.longitude),
      travelMode: getTradeMode(commuteMode),
      wayPoints: [
        PolylineWayPoint(location: "CISF 5TH RES BATT FAMILY QWARTERS ROAD")
      ],
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _addPolyLine();
  }
}
