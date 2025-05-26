import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class User_Map extends StatefulWidget {
  const User_Map({super.key});

  @override
  State<User_Map> createState() => User_MapState();
}

class User_MapState extends State<User_Map> {
  final Completer<GoogleMapController> _googleMapController = Completer();
  final Location _location = Location();

  LatLng _userPosition = const LatLng(32.059149, 35.877001);
  StreamSubscription<LocationData>? _locationSubscription;

  late BitmapDescriptor _customMarkerIcon;
  bool _isMarkerReady = false;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _initLocationTracking();
  }

  Future<void> _loadCustomMarker() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'lib/images/pin78.png',
    );
    setState(() {
      _isMarkerReady = true;
    });
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _userPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
      _moveCamera(_userPosition);
    });
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isMarkerReady
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userPosition,
                zoom: 16,
              ),
              onMapCreated: (controller) {
                _googleMapController.complete(controller);
              },
              markers: {
                Marker(
                  markerId: const MarkerId('user'),
                  position: _userPosition,
                  icon: _customMarkerIcon,
                  infoWindow: const InfoWindow(title: "You"),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
