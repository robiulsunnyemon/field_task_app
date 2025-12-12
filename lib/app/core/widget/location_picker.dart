
import 'package:field_task_app/app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../modules/create_task/controllers/create_task_controller.dart';


class LocationPickerScreen extends StatelessWidget {

  final controller=Get.find<CreateTaskController>();
  final MapController mapController = MapController();
  final Rx<LatLng> selectedLocation = LatLng(23.777176, 90.399452).obs; // Dhaka Default

  LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {


    if (controller.lati.isNotEmpty && controller.longi.isNotEmpty) {
      final initialLat = double.tryParse(controller.lati.value) ?? 23.777176;
      final initialLon = double.tryParse(controller.longi.value) ?? 90.399452;
      selectedLocation.value = LatLng(initialLat, initialLon);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Task Location'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedLocation.value,
              initialZoom: 14.0,
              onTap: (tapPosition, latlng) {
                selectedLocation.value = latlng;
                print('Location Selected: ${latlng.latitude}, ${latlng.longitude}');
              },
            ),
            children: [

              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.fieldtaskapp',
              ),


              Obx(() => MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: selectedLocation.value,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                ],
              )),


              Center(
                child: IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    child: const Icon(
                      Icons.add_circle,
                      color: Colors.black54,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),


          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                controller.setLocation(
                  selectedLocation.value.latitude,
                  selectedLocation.value.longitude,
                );
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Confirm Location',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

