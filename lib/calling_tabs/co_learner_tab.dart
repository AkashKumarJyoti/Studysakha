import 'package:flutter/material.dart';

import '../calling_screens/co-learners.dart';
import '../utils/term_and_condition.dart';

class CoLearnerTab extends StatelessWidget {
  const CoLearnerTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(children: [
            Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF5799F7), Color(0xFF3ADF75)])),
                child: Row(
                  children: <Widget>[
                    Image.asset('images/graphics.png'),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Connect with Co-Learners",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 3.0),
                                Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text("Call & Practice English",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                )),
            Positioned(
              bottom: 4,
              right: 6,
              child: SizedBox(
                height: 32,
                width: 85,
                child: TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return const CoLearners();
                        },
                      ));
                    },
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.call, size: 16, color: Color(0xFF2E56AF)),
                        Text("Call Now",
                            style: TextStyle(
                                color: Color(0xFF2E56AF), fontSize: 12))
                      ],
                    )),
              ),
            )
          ]),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/2 - 35,
          child: ListView(
            children:[
              const Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Terms and Condition", style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  )),
                ),
              ),
              termAndCondition(context),
              const SizedBox(height: 12),
              termAndCondition(context),
              const SizedBox(height: 12),
              termAndCondition(context),
              const SizedBox(height: 12),
              termAndCondition(context),
              const SizedBox(height: 12),
              termAndCondition(context),const SizedBox(height: 12),
              termAndCondition(context)
            ]
          ),
        ),

      ],
    );
  }
}
