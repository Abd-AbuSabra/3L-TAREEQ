import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapTrack extends StatefulWidget {
  const MapTrack({Key? key}) : super(key: key);

  @override
  State<MapTrack> createState() => _MapTrackState();
}

class _MapTrackState extends State<MapTrack> {
  GoogleMapController? _mapController;
  Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;


  LatLng _userPos = const LatLng(32.0425, 35.9305);
  LatLng _providerPos = const LatLng(32.0325, 35.9405);
  
  String _travelTime = 'Calculating...';
  String _distance = 'Calculating...';

  BitmapDescriptor? _userIcon;
  BitmapDescriptor? _providerIcon;

  Timer? _locationUpdateTimer;
  Timer? _providerUpdateTimer;
  Timer? _infoUpdateTimer;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
    _initializeLocation();
  }

  Future<void> _loadCustomIcons() async {
    try {
      _userIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(60, 60)),
        'lib/images/pin78.png',
      );
      _providerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(60, 60)),
        'lib/images/pin78.png',
      );
      setState(() {});
    } catch (e) {
      print('Error loading custom icons: $e');
    }
  }

  Future<void> _initializeLocation() async {
 
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

  
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

 
    _locationData = await _location.getLocation();
    if (_locationData != null) {
      setState(() {
        _userPos = LatLng(
          _locationData!.latitude!,
          _locationData!.longitude!,
        );
        
      
        _providerPos = _calculateProviderPosition(_userPos, 2500);
      });
      
    
      _startLocationUpdates();
      _calculateDistance();
      _isInitialized = true;
    }
  }
  
  LatLng _calculateProviderPosition(LatLng userPos, double distanceInMeters) {
  
    const double earthRadius = 6378137.0;
    
   
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    
 
    final distanceRadians = distanceInMeters / earthRadius;
    

    final userLat = userPos.latitude * pi / 180;
    final userLng = userPos.longitude * pi / 180;
    
  
    final newLat = asin(sin(userLat) * cos(distanceRadians) + 
                      cos(userLat) * sin(distanceRadians) * cos(angle));
                      
    final newLng = userLng + atan2(sin(angle) * sin(distanceRadians) * cos(userLat),
                               cos(distanceRadians) - sin(userLat) * sin(newLat));

    return LatLng(newLat * 180 / pi, newLng * 180 / pi);
  }
  
  void _startLocationUpdates() {
   
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted && _isInitialized) {
        setState(() {
          _userPos = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
        
       
        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(_userPos));
        }
      }
    });
    
 
    _providerUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {

        final double dx = _userPos.latitude - _providerPos.latitude;
        final double dy = _userPos.longitude - _providerPos.longitude;
        
  
        final double currentDistance = _calculateHaversineDistance(_userPos, _providerPos);
        
      
        final double targetDistance = 2.5; 
        
     
        double factor = 0.2;
        if (currentDistance > targetDistance * 1.5) {
          // Provider is too far, move faster toward user
          factor = 0.4;
        } else if (currentDistance < targetDistance * 0.8) {
          // Provider is too close, slow down or adjust path
          factor = 0.05;
        }
        
        _providerPos = LatLng(
          _providerPos.latitude + dx * factor,
          _providerPos.longitude + dy * factor
        );
      });
    });
    
    _infoUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _calculateDistance();
      } else {
        timer.cancel();
      }
    });
  }
  
  double _calculateHaversineDistance(LatLng point1, LatLng point2) {
    const int earthRadius = 6371; 
    
    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;
    
    double dlon = lon2 - lon1;
    double dlat = lat2 - lat1;
    
    double a = pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c; 
  }
  
  void _calculateDistance() {
    double distance = _calculateHaversineDistance(_userPos, _providerPos);
    

    double timeInMinutes = 5.0;
    
    if (distance < 1.5) {
      timeInMinutes = 3.0;
    } else if (distance > 3.5) {
      timeInMinutes = 7.0;
    }
    
  
    String distanceStr;
    if (distance < 1) {
      distanceStr = '${(distance * 1000).round()} m';
    } else {
      distanceStr = '${distance.toStringAsFixed(1)} km';
    }
    
    String timeStr;
    if (timeInMinutes >= 60) {
      int hours = (timeInMinutes / 60).floor();
      int mins = (timeInMinutes % 60).round();
      timeStr = '$hours hr${hours > 1 ? 's' : ''} $mins min${mins != 1 ? 's' : ''}';
    } else {
      timeStr = '${timeInMinutes.round()} mins';
    }
    
    setState(() {
      _distance = distanceStr;
      _travelTime = timeStr;
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _providerUpdateTimer?.cancel();
    _infoUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('user'),
        position: _userPos,
        infoWindow: const InfoWindow(title: 'You'),
        icon: _userIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('provider'),
        position: _providerPos,
        infoWindow: const InfoWindow(title: 'Provider'),
        icon: _providerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('track_line'),
        color: const Color.fromARGB(255, 192, 228, 194),
        width: 8,
        points: [_userPos, _providerPos],
      ),
    };

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userPos,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
              controller.animateCamera(CameraUpdate.newLatLng(_userPos));
            },
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 7, 65, 115).withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.social_distance, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Distance: $_distance',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated Time: $_travelTime',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _initializeLocation(); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updating location...'), duration: Duration(seconds: 1)),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}