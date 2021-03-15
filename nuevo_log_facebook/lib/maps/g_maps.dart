import 'dart:async';
import 'dart:collection';
import 'dart:convert' show json;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Gmaps extends StatefulWidget {
  @override
  State createState() => GmapsState();
}

class GmapsState extends State<Gmaps> {
  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController _mapController;
  BitmapDescriptor _icono_inseguro;
  BitmapDescriptor _icono_seguro;

  @override
  void initState() {
    super.initState();
    _iconoAlertaInseguro();
    _iconoAlertaSeguro();
  }

  void _iconoAlertaInseguro() async {
    _icono_inseguro = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/peligro.png');
  }

  void _iconoAlertaSeguro() async {
    _icono_seguro = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/policia2.png');
  }

  void _mapControl(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId("0"),
            position: LatLng(-16.39889, -71.535),
            infoWindow: InfoWindow(
                title: "Centro de Arequipa",
                snippet: "Zona segura para transitar, libre de peligros"),
            icon: _icono_seguro),
      );
      _markers.add(Marker(
          markerId: MarkerId("1asd"),
          position: LatLng(-16.39879, -71.538),
          infoWindow: InfoWindow(
              title: "Centro de Arequipa", snippet: "Zona No Segura, Robo"),
          icon: _icono_inseguro));
    });
  }

  // TODO: implement widget
  Widget build(BuildContext context) {
    LatLng latLng = LatLng(-16.39889, -71.535);
    //CameraPosition cameraPosition = CameraPosition(target: latLng);

    return Scaffold(
      appBar: AppBar(
        title: Text("Alerta Arequipa"),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _mapControl,
            initialCameraPosition: CameraPosition(
              target: latLng,
              zoom: 15,
            ),
            markers: _markers,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
            child: Text("Alerta Arequipa"),
          ),
        ],
      ),
    );
  }
}
