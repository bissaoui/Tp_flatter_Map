import 'package:flutter/material.dart';

class MyHeaderDrawer extends StatefulWidget {
  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[600],
      width: double.infinity,
      height: 250,
      padding: EdgeInsets.only(top: 60.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5),
            height: 105,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/me.jpg'),
              ),
            ),
          ),
          Text(
            "BISSAOUI YASSINE",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            "yassine.bissaoui@gmail.com",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
