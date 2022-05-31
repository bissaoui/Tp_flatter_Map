import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/resturants.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShwCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: "assets/images/logo.png",
      backgroundColor: Colors.lightBlue,
      nextScreen: HomePage(),
      splashIcoSize: 450,
      duration: 3000,
      splashTransition: SplashTransition.scaleTransition,
      pageTransitionType: PageTransitionType.leftToRight,
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState creatmeState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var cpg = DrawerSections.home;

  @override
  Widget build(BuildContext context) {
    var container;
    if (cpg == DrawerSections.home) {
      container = HomeePage();
    } else if (cpg = DrawerSections.patesserie) {
      container = FoodLocations();
    } else if (cpg == DrawerSections.google) {
      container = GoogleOffcies();
    }
    else if (cpg == DrawerSections.restau) {
      container = ResturantsLocation();
    }
    return Scaffold(
      appBar: Appar(
        backgrounldColor: Colors.blue[700],
        title: Text("MapFlutter"),
      ),
      body: container,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                MyHeaderDrawer(),
                MyDrawerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
      padding: EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        children: [
          menuItem(1, "Home Page", Icons.ad_units,
              cpg == DrawerSections.home ? true : false),
          menuItem(2, "Patesseries", Icons.fastfood_sharp,
              cpg == DrawerSections.patesserie ? true : false),
          menuItem(3, "Google offices", Icons.local_post_office_outlined,
              cpg == DrawerSections.google ? true : false),
          menuItem(4, "Resturants", Icons.restaurant,
              cpg == DrawerSections.restau ? true : false)
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
      color: selected ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          setState(() {
            if (id == 1) {
              cpg = DrawerSections.home;
            } else if (id == 2) {
              cpg = DrawerSections.patesserie;
            } else if (id == 3) {
              cpg = DrawerSections.google;
            }else if (id == 4) {
              cpg = DrawerSections.restau;
            }
          });
        },
        child: Padding(

          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 19,
                  color: Colors.black54,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DrawerSections {
  home,
  patesserie,
  google,
  restau
}
