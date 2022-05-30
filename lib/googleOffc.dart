import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/google.dart' as locations;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' as math;

void main() {
  runApp(const GoogleOffcies());
}

class GoogleOffcies extends StatefulWidget {
  const GoogleOffcies({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<GoogleOffcies> {
  double range=50000;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;

  @override
  void initState(){
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose(){
    textEditingController.dispose();
    super.dispose();
  }
  final Map<String, Marker> _markers = {};
  final Map<String, Circle> _circles = {};
  final Map<String, Polyline> _lines = {};
  LatLng curent_position =  LatLng(0, 0);
  Future<void> _onMapCreated(GoogleMapController controller) async {
    googleMapController = controller;
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
            onTap: ()async{
              PolylinePoints polylinePoints = PolylinePoints();
              PolylineResult result = await polylinePoints.getRouteBetweenCoordinates("AIzaSyDs1YfiMMHHgNXAqHYNlX8lPBsyIPVUgQc",
                PointLatLng(curent_position.latitude, curent_position.longitude),
                PointLatLng(office.lat, office.lng),travelMode: TravelMode.driving,
              );



              List<LatLng> polylineCoordinates = <LatLng>[];

              if (result.points.isNotEmpty) {
                result.points.forEach((PointLatLng point) {
                  polylineCoordinates.add(LatLng(point.latitude, point.longitude));

                });
              }

              setState(() {
                Polyline polyline = Polyline(
                    polylineId: PolylineId('poly'),
                    color: Colors.blue,
                    points: polylineCoordinates);

                _lines["poly"] = polyline;

                print("AiroShooter");
              });

            },
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  double getZoomLevel(double radius) {
    double zoomLevel = 11;
    if (radius > 0) {
      double radiusElevated = radius + radius / 2;
      double scale = radiusElevated / 500;
      zoomLevel = 16 - math.log(scale) / math.log(2);
    }
    zoomLevel = num.parse(zoomLevel.toStringAsFixed(2)) as double;
    return zoomLevel;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          onLongPress:(LatLng) async{
            final trange = await openDialog();

            setState(() {
              this.range = num.parse(trange as String).toDouble();
            });
          },
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          markers: _markers.values.toSet(),
          circles: _circles.values.toSet(),
          polylines:_lines.values.toSet(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed:() async {
            Position position = await getPostion();
            googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:LatLng(position.latitude, position.longitude),zoom: getZoomLevel(this.range))));
            final marker = Marker(
              markerId: MarkerId("myPos"),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: InfoWindow(
                title: "your current place",
              ),
            );


            final circle = Circle(
              circleId: CircleId("circle"),
              center: LatLng(position.latitude,position.longitude),
              radius: this.range,
              strokeColor: Color.fromRGBO(232, 83, 205, 0.6),
              strokeWidth: 1,
              fillColor: Color.fromRGBO(186, 56, 56, 0.1568627450980392),
            );



            setState(() {
              _markers["myPos"]=marker;
              _circles["circle"]=circle;
              curent_position = LatLng(position.latitude, position.longitude);
            });



          },
          backgroundColor: Colors.blue[700], label: Text("next to me"),icon: Icon(Icons.map),
        ),
        floatingActionButtonLocation:    FloatingActionButtonLocation.startFloat,
      ),
    );
  }


  Future<Position> getPostion() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await  Geolocator.isLocationServiceEnabled();

    if(!serviceEnabled){
      return Future.error("Locations services are disabled");
    }

    permission = await Geolocator.checkPermission();

    if(permission==LocationPermission.denied){
      permission = await Geolocator.requestPermission();

      if(permission==LocationPermission.denied){
        return Future.error("Locations permission denied");
      }
    }

    if(permission == LocationPermission.deniedForever){
      return Future.error("Locations permission are permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  Future<String?> openDialog() => showDialog<String>(
    context: context,
    builder: (context)=>AlertDialog(
      title: Text("Edit Range"),
      content: TextField(
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(hintText: "30 or 3000"),
        controller: textEditingController,
      ),
      actions: [
        TextButton(onPressed: ()async{
          Navigator.of(context).pop(textEditingController.text);
        }, child: Text("Ok"))
      ],
    ),

  );

}