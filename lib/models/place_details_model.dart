// To parse this JSON data, do
//
//     final placeDetailModel = placeDetailModelFromJson(jsonString);

import 'dart:convert';

PlaceDetailModel placeDetailModelFromJson(String str) =>
    PlaceDetailModel.fromJson(json.decode(str));

String placeDetailModelToJson(PlaceDetailModel data) =>
    json.encode(data.toJson());

class PlaceDetailModel {
  List<AddressComponent>? addressComponents;
  String? adrAddress;
  String? formattedAddress;
  Geometry? geometry;
  String? icon;
  String? iconBackgroundColor;
  String? iconMaskBaseUri;
  String? name;
  List<Photo>? photos;
  String? placeId;
  String? reference;
  List<String>? types;
  String? url;
  int? utcOffset;
  String? vicinity;

  PlaceDetailModel({
    this.addressComponents,
    this.adrAddress,
    this.formattedAddress,
    this.geometry,
    this.icon,
    this.iconBackgroundColor,
    this.iconMaskBaseUri,
    this.name,
    this.photos,
    this.placeId,
    this.reference,
    this.types,
    this.url,
    this.utcOffset,
    this.vicinity,
  });

  factory PlaceDetailModel.fromJson(Map<String, dynamic> json) =>
      PlaceDetailModel(
        addressComponents: json["address_components"] == null
            ? []
            : List<AddressComponent>.from(json["address_components"]!
                .map((x) => AddressComponent.fromJson(x))),
        adrAddress: json["adr_address"],
        formattedAddress: json["formatted_address"],
        geometry: json["geometry"] == null
            ? null
            : Geometry.fromJson(json["geometry"]),
        icon: json["icon"],
        iconBackgroundColor: json["icon_background_color"],
        iconMaskBaseUri: json["icon_mask_base_uri"],
        name: json["name"],
        photos: json["photos"] == null
            ? []
            : List<Photo>.from(json["photos"]!.map((x) => Photo.fromJson(x))),
        placeId: json["place_id"],
        reference: json["reference"],
        types: json["types"] == null
            ? []
            : List<String>.from(json["types"]!.map((x) => x)),
        url: json["url"],
        utcOffset: json["utc_offset"],
        vicinity: json["vicinity"],
      );

  Map<String, dynamic> toJson() => {
        "address_components": addressComponents == null
            ? []
            : List<dynamic>.from(addressComponents!.map((x) => x.toJson())),
        "adr_address": adrAddress,
        "formatted_address": formattedAddress,
        "geometry": geometry?.toJson(),
        "icon": icon,
        "icon_background_color": iconBackgroundColor,
        "icon_mask_base_uri": iconMaskBaseUri,
        "name": name,
        "photos": photos == null
            ? []
            : List<dynamic>.from(photos!.map((x) => x.toJson())),
        "place_id": placeId,
        "reference": reference,
        "types": types == null ? [] : List<dynamic>.from(types!.map((x) => x)),
        "url": url,
        "utc_offset": utcOffset,
        "vicinity": vicinity,
      };
}

class AddressComponent {
  String? longName;
  String? shortName;
  List<String>? types;

  AddressComponent({
    this.longName,
    this.shortName,
    this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      AddressComponent(
        longName: json["long_name"],
        shortName: json["short_name"],
        types: json["types"] == null
            ? []
            : List<String>.from(json["types"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "long_name": longName,
        "short_name": shortName,
        "types": types == null ? [] : List<dynamic>.from(types!.map((x) => x)),
      };
}

class Geometry {
  Location? location;
  Viewport? viewport;

  Geometry({
    this.location,
    this.viewport,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        viewport: json["viewport"] == null
            ? null
            : Viewport.fromJson(json["viewport"]),
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "viewport": viewport?.toJson(),
      };
}

class Location {
  double? lat;
  double? lng;

  Location({
    this.lat,
    this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Viewport {
  Location? northeast;
  Location? southwest;

  Viewport({
    this.northeast,
    this.southwest,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
        northeast: json["northeast"] == null
            ? null
            : Location.fromJson(json["northeast"]),
        southwest: json["southwest"] == null
            ? null
            : Location.fromJson(json["southwest"]),
      );

  Map<String, dynamic> toJson() => {
        "northeast": northeast?.toJson(),
        "southwest": southwest?.toJson(),
      };
}

class Photo {
  int? height;
  List<String>? htmlAttributions;
  String? photoReference;
  int? width;

  Photo({
    this.height,
    this.htmlAttributions,
    this.photoReference,
    this.width,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        height: json["height"],
        htmlAttributions: json["html_attributions"] == null
            ? []
            : List<String>.from(json["html_attributions"]!.map((x) => x)),
        photoReference: json["photo_reference"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "html_attributions": htmlAttributions == null
            ? []
            : List<dynamic>.from(htmlAttributions!.map((x) => x)),
        "photo_reference": photoReference,
        "width": width,
      };
}
