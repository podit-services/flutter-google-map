import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goolge_map_demo/custom_tile.dart';
import 'package:goolge_map_demo/screens/auto_complete_place.dart';
import 'package:goolge_map_demo/screens/map_with_marker.dart';
import 'package:goolge_map_demo/screens/polyline_screen.dart';
import 'package:goolge_map_demo/screens/user_location.dart';

import 'screens/default_map.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Google Maps"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CustomTile(
            title: "Default Map",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DefaultMap(),
                ),
              );
            },
          ),
          CustomTile(
            title: "Map with marker",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MapWithMarker(),
                ),
              );
            },
          ),
          CustomTile(
            title: "User Current Location",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserLocation(),
                ),
              );
            },
          ),
          CustomTile(
            title: "Auto Complete Place",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AutoCompletePlace(),
                ),
              );
            },
          ),
          CustomTile(
            title: "Polyline Screen",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PolylineScreen(
                    origin: LatLng(28.6124766, 77.3591061),
                    destination: LatLng(28.7066554, 77.4224129),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
