import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  LatLng? _pointA;
  LatLng? _pointB;
  double? _distanceInKm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Points')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                37.7749,
                -122.4194,
              ), // Default location (San Francisco)
              zoom: 10,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (position) {
              setState(() {
                if (_pointA == null) {
                  _pointA = position;
                } else if (_pointB == null) {
                  _pointB = position;
                  _calculateDistance();
                } else {
                  _pointA = position;
                  _pointB = null;
                  _distanceInKm = null;
                }
              });
            },
            markers: {
              if (_pointA != null)
                Marker(
                  markerId: MarkerId('pointA'),
                  position: _pointA!,
                  infoWindow: InfoWindow(title: 'Point A'),
                ),
              if (_pointB != null)
                Marker(
                  markerId: MarkerId('pointB'),
                  position: _pointB!,
                  infoWindow: InfoWindow(title: 'Point B'),
                ),
            },
          ),
          if (_distanceInKm != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Distance: ${_distanceInKm!.toStringAsFixed(2)} km',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          _pointB != null
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context, _distanceInKm);
                },
                child: Icon(Icons.check, color: Colors.white),
              )
              : null,
    );
  }

  void _calculateDistance() {
    if (_pointA != null && _pointB != null) {
      final distance = Geolocator.distanceBetween(
        _pointA!.latitude,
        _pointA!.longitude,
        _pointB!.latitude,
        _pointB!.longitude,
      );
      setState(() {
        _distanceInKm = distance / 1000; // Convert meters to kilometers
      });
    }
  }
}
