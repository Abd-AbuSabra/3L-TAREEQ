import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Map_track extends StatefulWidget {
  const Map_track({super.key});

  @override
  State<Map_track> createState() => _Map_trackState();
}

class _Map_trackState extends State<Map_track> {
  final _controller = Completer<GoogleMapController>();
  final _location = Location();

  LatLng _userPos = const LatLng(32.059149, 35.877001);
  LatLng _providerPos = const LatLng(32.037277, 35.881276);

  StreamSubscription<LocationData>? _sub;
  Set<Polyline> _polylines = {};

  BitmapDescriptor? _userIcon;
  BitmapDescriptor? _providerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _trackLocation();
  }

  Future<void> _loadMarkers() async {
    _userIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'lib/images/pin78.png',
    );
    _providerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'lib/images/pin78.png',
    );
    setState(() {});
  }

  Future<void> _trackLocation() async {
    if (!await _location.serviceEnabled() && !await _location.requestService()) return;
    if (await _location.hasPermission() == PermissionStatus.denied &&
        await _location.requestPermission() != PermissionStatus.granted) return;

    _sub = _location.onLocationChanged.listen((loc) {
      if (loc.latitude == null || loc.longitude == null) return;

      setState(() {
        _userPos = LatLng(loc.latitude!, loc.longitude!);
        _providerPos = LatLng(loc.latitude! + 0.0015, loc.longitude! + 0.0015);
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: [_userPos, _providerPos],
            color: const Color.fromARGB(255, 192, 228, 194),
            width: 8,
          ),
        };
      });

      _moveCamera();
    });
  }

  Future<void> _moveCamera() async {
    final controller = await _controller.future;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _userPos.latitude < _providerPos.latitude ? _userPos.latitude : _providerPos.latitude,
        _userPos.longitude < _providerPos.longitude ? _userPos.longitude : _providerPos.longitude,
      ),
      northeast: LatLng(
        _userPos.latitude > _providerPos.latitude ? _userPos.latitude : _providerPos.latitude,
        _userPos.longitude > _providerPos.longitude ? _userPos.longitude : _providerPos.longitude,
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _userPos, zoom: 14),
        onMapCreated: _controller.complete,
        markers: {
          Marker(
            markerId: const MarkerId('user'),
            position: _userPos,
            icon: _userIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: "User"),
          ),
          Marker(
            markerId: const MarkerId('provider'),
            position: _providerPos,
            icon: _providerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: "Provider"),
          ),
        },
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
