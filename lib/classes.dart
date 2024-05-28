import 'package:flutter/material.dart';
import 'package:studysakha_calling/rooms/live_rooms.dart';
import 'package:studysakha_calling/rooms/upcoming_rooms.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  bool refresh = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF08FFB8), Color(0xFF5799F7)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                  top: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 15.0),
                    Image.asset('images/menu_icon.png'),
                    const SizedBox(width: 15.0),
                    const Text(
                      "Room",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                        onTap: ()
                        {
                          setState(() {
                            refresh = !refresh;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.refresh, color: Colors.white, size: 25,),
                        ))
                  ],
                ),
              ),
            ),
        ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0, left: 15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Live Now",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black, // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                  LiveClass(refresh: refresh),

                  const Padding(
                    padding: EdgeInsets.only(top: 20.0, left: 15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Upcoming Rooms",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black, // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                  UpcomingClasses(refresh: refresh),
                ],
              ),
            ),
            ],
        ),
          ],
        ),
      ),
    );
  }
}