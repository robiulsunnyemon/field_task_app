
import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LocationService extends GetxService {

  final Rx<Position?> _currentPosition = Rx<Position?>(null);



  final Rx<ConnectivityResult> _connectivityResult = Rx<ConnectivityResult>(ConnectivityResult.none);
  bool get hasInternet => _connectivityResult.value != ConnectivityResult.none;


  Rx<ConnectivityResult> get connectivityResultStream => _connectivityResult;
  Rx<Position?> get currentPositionStream => _currentPosition;

  Position? get currentPosition => _currentPosition.value;

  late StreamSubscription<Position> _positionStreamSubscription;


  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();


    _checkLocationPermissions();


    _startLocationStream();


    _startConnectivityStream();
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
  }

  void _startLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _currentPosition.value = position;
    });
  }


  void _startConnectivityStream() {


    Connectivity().checkConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _connectivityResult.value = results.first;
      }
    });


    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _connectivityResult.value = results.first;
      }
    });
  }


  double getDistanceInMeters(double taskLat, double taskLon) {
    if (_currentPosition.value == null) return double.infinity;

    return Geolocator.distanceBetween(
      _currentPosition.value!.latitude,
      _currentPosition.value!.longitude,
      taskLat,
      taskLon,
    );
  }

  @override
  void onClose() {
    _positionStreamSubscription.cancel();
    _connectivitySubscription.cancel();
    super.onClose();
  }
}