import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_points/google_polyline_points.dart';
import 'package:goolge_map_demo/models/place_details_model.dart';
import 'package:goolge_map_demo/models/prediction_model.dart';
import 'package:goolge_map_demo/screens/polyline_screen.dart';
import 'package:http/http.dart' as http;

class AutoCompletePlace extends StatefulWidget {
  const AutoCompletePlace({super.key});

  @override
  State<AutoCompletePlace> createState() => _AutoCompletePlaceState();
}

class _AutoCompletePlaceState extends State<AutoCompletePlace> {
  final startingController = TextEditingController();
  final destinationController = TextEditingController();
  List<Prediction> predictions = [];
  bool isDataAvailable = false;
  Prediction prediction = Prediction();
  PlaceDetailModel placeDetails = PlaceDetailModel();

  String? currentAddress;
  String country = "";
  Position? currentPosition;

  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  Set<Marker> createMarker() {
    return {
      Marker(
        markerId: MarkerId("${placeDetails.placeId}"),
        position: LatLng(placeDetails.geometry?.location!.lat! ?? 0.00,
            placeDetails.geometry?.location!.lng! ?? 0.00),
        infoWindow: InfoWindow(title: "${placeDetails.name}"),
        rotation: 0,
      ),
      Marker(
        markerId: const MarkerId("Marker 1"),
        position: LatLng(
          currentPosition?.latitude ?? 0.00,
          currentPosition?.longitude ?? 0.00,
        ),
        infoWindow: const InfoWindow(title: "Current Location"),
        rotation: 0,
      ),
    };
  }

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  void getSuggestions(String input) async {
    String kGoogleMapKey = dotenv.env['GOOGLE_MAP_API_KEY']!;
    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String url =
        "$baseUrl?key=$kGoogleMapKey&&waypoints=place_id:ChIJh05Dlb3lDDkRS1zoxPQlDbk&components=country:$country&input=$input";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      predictions.clear();
      List<dynamic> _predictions = jsonDecode(response.body)['predictions'];
      List<Prediction> tempList = [];
      for (var element in _predictions) {
        Prediction prediction = Prediction.fromJson(element);
        tempList.add(prediction);
      }
      setState(() {
        isDataAvailable = true;
        predictions.addAll(tempList);
      });
      PolylinePoints polylinePoints = PolylinePoints();
      List<LatLngCoordinate> result = polylinePoints.decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
      print(result);
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
      PlaceDetailModel _place =
          PlaceDetailModel.fromJson(responseData['result']);
      setState(() {
        placeDetails = _place;
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

  Future<void> _getAddressFromLatLng(Position position) async {
    String kGoogleMapKey = dotenv.env['GOOGLE_MAP_API_KEY']!;
    String baseUrl = "https://maps.googleapis.com/maps/api";
    String geocodeUrl = "$baseUrl/geocode/json";
    String lat = "${position.latitude}";
    String lng = "${position.longitude}";
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
        currentPosition = position;
      });
      _getAddressFromLatLng(currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Auto Complete Places API"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: startingController,
              decoration: InputDecoration(
                hintText: "Your Location",
                contentPadding: const EdgeInsets.all(16.0),
                enabledBorder: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  ),
                ),
                errorBorder: const OutlineInputBorder(),
                focusedErrorBorder: const OutlineInputBorder(),
              ),
              onTap: () {
                setState(() {
                  isDataAvailable = false;
                });
              },
              onChanged: (String value) {
                getSuggestions(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: destinationController,
              decoration: InputDecoration(
                hintText: "Choose destination",
                contentPadding: const EdgeInsets.all(16.0),
                enabledBorder: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  ),
                ),
                errorBorder: const OutlineInputBorder(),
                focusedErrorBorder: const OutlineInputBorder(),
              ),
              onTap: () {
                setState(() {
                  isDataAvailable = false;
                });
              },
              onChanged: (String value) {
                getSuggestions(value);
              },
            ),
          ),
          Expanded(
            child: isDataAvailable
                ? ListView.separated(
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
                        onTap: () {
                          setState(() {
                            prediction = _prediction;
                            isDataAvailable = true;
                          });
                          destinationController.text =
                              prediction.structuredFormatting?.mainText ?? "";
                          predictions.clear();
                          FocusScope.of(context).unfocus();
                          getPlaceDetail(prediction.placeId ?? "");
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8.0);
                    },
                    itemCount: predictions.length,
                  )
                : Container()
          ),
          ElevatedButton(
            onPressed: () {

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PolylineScreen(
                    origin: LatLng(
                      currentPosition?.latitude ?? 0.00,
                      currentPosition?.longitude ?? 0.0,
                    ),
                    destination: LatLng(
                      placeDetails.geometry?.location?.lat ?? 0.0,
                      placeDetails.geometry?.location?.lng ?? 0.0,
                    ),
                  ),
                ),
              );
            },
            child: Text("Go to Map"),
          ),
        ],
      ),
    );
  }
}
