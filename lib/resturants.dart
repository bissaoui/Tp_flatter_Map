import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/restu.dart' as restau;
import 'dart:math' as math;

void main() {
  runApp(const ResturantsLocation());
}

class ResturantsLocation extends StatefulWidget {
  const ResturantsLocation({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<ResturantsLocation> {
  double rng=50000;
  late GoogleMapController googleMapC;
  late TextEditingController txtEdittingC;
  @override
  void initState(){
    super.initState();
    txtEdittingC = TextEditingController();
  }

  @override
  void dispose(){
    txtEdittingC.dispose();
    super.dispose();
  }
  final Map<String, Marker> _markers = {};
  final Map<String, Circle> _circles = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    googleMapC = controller;
    final returants = await restau.getResturants();
    setState(() {
      _markers.clear();
      for (final resturant in returants.results) {
        final marker = Marker(
          markerId: MarkerId(resturant.name!),
          position: LatLng(resturant.geometry!.location!.lat!,resturant.geometry!.location!.lng!),
          infoWindow: InfoWindow(
            title: resturant.name!,
            snippet: resturant.formattedAddress!,
          ),
        );
        _markers[resturant.name!] = marker;
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
            final trng = await openDialog();

            setState(() {
              this.rng = num.parse(trng as String).toDouble();
              print("range "+this.rng.toString());
            });
          },
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          markers: _markers.values.toSet(),
          circles: _circles.values.toSet(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed:() async {
            Position position = await getPostion();
            googleMapC.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:LatLng(position.latitude, position.longitude),zoom: getZoomLevel(this.rng))));
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
              radius: this.rng,
              strokeColor: Color.fromRGBO(232, 83, 205, 0.6),
              strokeWidth: 1,
              fillColor: Color.fromRGBO(186, 56, 56, 0.1568627450980392),
            );

            setState(() {
              _markers["myPos"]=marker;
              _circles["circle"]=circle;
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
        controller: txtEdittingC,
      ),
      actions: [
        TextButton(onPressed: ()async{
          Navigator.of(context).pop(txtEdittingC.text);
        }, child: Text("Ok"))
      ],
    ),

  );

}