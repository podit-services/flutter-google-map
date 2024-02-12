import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_points/google_polyline_points.dart';
import 'package:http/http.dart' as http;

import '../models/place_details_model.dart';
import '../models/prediction_model.dart';

class MapWithMarker extends StatefulWidget {
  const MapWithMarker({super.key});

  @override
  State<MapWithMarker> createState() => _MapWithMarkerState();
}

class _MapWithMarkerState extends State<MapWithMarker> {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  final startingController = TextEditingController();
  final destinationController = TextEditingController();
  List<Prediction> predictions = [];
  bool isDataAvailable = false;
  Prediction prediction = Prediction();

  String? currentAddress;
  String country = "";
  LatLng? startingPosition;
  LatLng? destinationPosition;

  LatLng kMapCenter = const LatLng(28.6927283, 77.3439278);

  CameraPosition kInitialPosition = const CameraPosition(
    target: LatLng(28.6927283, 77.3439278),
    zoom: 15.0,
    tilt: 0,
    bearing: 0,
  );

  getMyLocation() {
    setState(() {
      kInitialPosition =
          CameraPosition(target: kMapCenter, zoom: 15.0, tilt: 0, bearing: 0);
    });
  }

  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      log("ERROR: $error");
    });
    return await Geolocator.getCurrentPosition();
  }

  /// Get Suggestions from the api
  void getSuggestions(String input) async {
    String kGoogleMapKey = dotenv.env['GOOGLE_MAP_API_KEY']!;
    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String url =
        "$baseUrl?key=$kGoogleMapKey&&waypoints=place_id:ChIJh05Dlb3lDDkRS1zoxPQlDbk&components=country:$country&input=$input";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      predictions.clear();
      List<dynamic> predictionsList = jsonDecode(response.body)['predictions'];
      List<Prediction> tempList = [];
      for (var element in predictionsList) {
        Prediction prediction = Prediction.fromJson(element);
        tempList.add(prediction);
      }
      setState(() {
        isDataAvailable = true;
        predictions.addAll(tempList);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  getPlaceDetail(String placeId) async {
    log('In getPlaceDetail | Place ID: $placeId', name: 'AutoCompletePlace');
    String kGoogleMapKey = dotenv.env['GOOGLE_MAP_API_KEY']!;
    String baseUrl = "https://maps.googleapis.com/maps/api";
    String placeUrl = "$baseUrl/place";
    String url = "$placeUrl/details/json?key=$kGoogleMapKey&place_id=$placeId";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      PlaceDetailModel placeDetail =
          PlaceDetailModel.fromJson(responseData['result']);
      setState(() {
        destinationPosition = LatLng(
          placeDetail.geometry?.location?.lat ?? 0.0,
          placeDetail.geometry?.location?.lng ?? 0.0,
        );
      });
    } else {
      throw Exception('Not found');
    }
    log('Out getPlaceDetail', name: "AutoCompletePlace");
  }

  // User location
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    String kGoogleMapKey = dotenv.env['GOOGLE_MAP_API_KEY']!;
    String baseUrl = "https://maps.googleapis.com/maps/api";
    String geocodeUrl = "$baseUrl/geocode/json";
    String lat = "${latLng.latitude}";
    String lng = "${latLng.longitude}";
    String url = "$geocodeUrl?key=$kGoogleMapKey&latlng=$lat,$lng";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      List<dynamic> addressComponents =
          responseData['results'][0]['address_components'];
      Map<String, dynamic> countryMap = addressComponents
          .firstWhere((element) => element['types'].contains('country'));
      setState(() {
        startingController.text =
            responseData['results'][1]['formatted_address'];
        country = countryMap['short_name'].toLowerCase();
      });
    } else {
      throw Exception('Not found');
    }
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        startingPosition = LatLng(position.latitude, position.longitude);
      });
      _getAddressFromLatLng(startingPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  List<Marker> markers = [];

  bool showCurrentLocation = false;
  bool showSearchScreen = false;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Map With Marker"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 16.0,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: startingController,
                    decoration: InputDecoration(
                      hintText: "Your Location",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(8.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        showSearchScreen = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.locationDot,
                  color: Colors.red,
                  size: 16.0,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: destinationController,
                    decoration: InputDecoration(
                      hintText: "Search here",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(8.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        showSearchScreen = true;
                      });
                    },
                    onChanged: (String value) {
                      getSuggestions(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: showSearchScreen == false
                ? GoogleMap(
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      mapController.complete(controller);
                    },
                    initialCameraPosition: kInitialPosition,
                    markers: Set<Marker>.of(markers),
                    polylines: Set<Polyline>.of(polylines.values),
                    onCameraMove: (CameraPosition position) {},
                    onCameraMoveStarted: () {
                      if (kMapCenter != kInitialPosition.target) {
                        setState(() {
                          showCurrentLocation = false;
                        });
                      }
                    },
                  )
                : ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      Prediction _prediction = predictions[index];
                      int matchedSubstring =
                          _prediction.matchedSubstrings![0].length! ?? 0;
                      return ListTile(
                        tileColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        title: RichText(
                          text: TextSpan(
                              text: _prediction.structuredFormatting?.mainText
                                  ?.substring(0, matchedSubstring),
                              style: GoogleFonts.quicksand(
                                color: Colors.grey[900],
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: _prediction
                                      .structuredFormatting?.mainText
                                      ?.substring(matchedSubstring),
                                  style: GoogleFonts.quicksand(
                                    color: Colors.grey[900],
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ]),
                        ),
                        subtitle: Text(
                          _prediction.structuredFormatting?.secondaryText ?? "",
                        ),
                        onTap: () async {
                          setState(() {
                            prediction = _prediction;
                            showSearchScreen = false;
                          });
                          destinationController.text =
                              prediction.structuredFormatting?.mainText ?? "";
                          predictions.clear();
                          FocusScope.of(context).unfocus();
                          await getPlaceDetail(prediction.placeId ?? "");
                          log("Origin: ${startingPosition.toString()}");
                          log("Destination: ${destinationPosition.toString()}");

                          /// origin marker
                          _addMarker(
                            startingPosition!,
                            "origin",
                            BitmapDescriptor.defaultMarker,
                          );

                          /// destination marker
                          _addMarker(
                            destinationPosition!,
                            "destination",
                            BitmapDescriptor.defaultMarkerWithHue(90),
                          );
                          await _getPolyline(
                            origin: startingPosition!,
                            destination: destinationPosition!,
                          );
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8.0);
                    },
                    itemCount: predictions.length,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          CameraPosition cameraPosition = CameraPosition(
            target: kMapCenter,
            zoom: 20,
          );

          final GoogleMapController controller = await mapController.future;
          controller
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          setState(() {
            showCurrentLocation = true;
          });
        },
        child: Icon(
          FontAwesomeIcons.locationCrosshairs,
          color: showCurrentLocation
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade900,
        ),
      ),
    );
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers.add(marker);
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

  _getPolyline({required LatLng origin, required LatLng destination}) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.env['GOOGLE_MAP_API_KEY']!,
      LatLngCoordinate(origin.latitude, origin.longitude),
      LatLngCoordinate(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
      wayPoints: [
        PolylineWayPoint(location: "CISF 5TH RES BATT FAMILY QWARTERS ROAD")
      ],
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    log("called addPolyline");
    _addPolyLine();
  }
}
