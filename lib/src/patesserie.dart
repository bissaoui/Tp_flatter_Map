import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart' show rootBundle;

class Place {
  Place({
    required this.type,
    required this.features,
  });
  late final String type;
  late final List<Features> features;

  Place.fromJson(Map<String, dynamic> json){
    type = json['type'];
    features = List.from(json['features']).map((e)=>Features.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['type'] = type;
    _data['features'] = features.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Features {
  Features({
    required this.geometry,
    required this.type,
    required this.properties,
  });
  late final Geometry geometry;
  late final String type;
  late final Properties properties;

  Features.fromJson(Map<String, dynamic> json){
    geometry = Geometry.fromJson(json['geometry']);
    type = json['type'];
    properties = Properties.fromJson(json['properties']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['geometry'] = geometry.toJson();
    _data['type'] = type;
    _data['properties'] = properties.toJson();
    return _data;
  }
}

class Geometry {
  Geometry({
    required this.type,
    required this.coordinates,
  });
  late final String type;
  late final List<double> coordinates;

  Geometry.fromJson(Map<String, dynamic> json){
    type = json['type'];
    coordinates = List.castFrom<dynamic, double>(json['coordinates']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['type'] = type;
    _data['coordinates'] = coordinates;
    return _data;
  }
}

class Properties {
  Properties({
    required this.category,
    required this.hours,
    required this.description,
    required this.name,
    required this.phone,
    required this.storeid,
  });
  late final String category;
  late final String hours;
  late final String description;
  late final String name;
  late final String phone;
  late final String storeid;

  Properties.fromJson(Map<String, dynamic> json){
    category = json['category'];
    hours = json['hours'];
    description = json['description'];
    name = json['name'];
    phone = json['phone'];
    storeid = json['storeid'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['category'] = category;
    _data['hours'] = hours;
    _data['description'] = description;
    _data['name'] = name;
    _data['phone'] = phone;
    _data['storeid'] = storeid;
    return _data;
  }
}
Future<Place> getPatessries() async {
  // Fallback for when the above HTTP request fails.
  return Place.fromJson(
    json.decode(
      await rootBundle.loadString('assets/patesserie.json'),
    ),
  );
}