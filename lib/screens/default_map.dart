import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DefaultMap extends StatelessWidget {
  const DefaultMap({super.key});

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> mapController =
        Completer<GoogleMapController>();

    const LatLng kMapCenter = LatLng(28.6123967, 77.3592717);

    const CameraPosition kInitialPosition =
        CameraPosition(target: kMapCenter, zoom: 15.0, tilt: 0, bearing: 0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Default Map"),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController.complete(controller);
        },
        initialCameraPosition: kInitialPosition,
      ),
    );
  }
}
