import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/patesserie.dart' as patesseries;
import 'dart:math' as math;

void main() {
  runApp(const FoodLocations());
}

class FoodLocations extends StatefulWidget {

  const FoodLocations({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<FoodLocations> {
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
    final places = await patesseries.getPatessries();
    setState(() {
      _markers.clear();
      for (final future in places.features) {
        final marker = Marker(
          markerId: MarkerId(future.properties.name),
          position: LatLng(future.geometry.coordinates[1], future.geometry.coordinates[0]),
          infoWindow: InfoWindow(
            title: future.properties.name,
            snippet: future.properties.description
          ),
        );
        _markers[future.properties.name] = marker;
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
          polylines: _lines.values.toSet(),
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