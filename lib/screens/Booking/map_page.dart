import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var location = Location();

  serviceEnabled() async {
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        return;
      }
    }
  }

  permissionGranted() async {
    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<double?> currentLatitude() async {
    var currentLocation = await location.getLocation();
    return currentLocation.latitude;
  }

  Future<double?> currentLongitude() async {
    var currentLocation = await location.getLocation();
    return currentLocation.longitude;
  }

  static const LatLng davaoLocation = LatLng(7.207573, 125.395874);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: davaoLocation, zoom: 13)),
    );
  }
}
