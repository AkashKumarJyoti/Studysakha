import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../call_page/call_page.dart';

class CoLearners extends StatefulWidget {
  const CoLearners({Key? key}) : super(key: key);

  @override
  State<CoLearners> createState() => _CoLearnersState();
}

class _CoLearnersState extends State<CoLearners> {
  bool is_available = false;
  void _showDialog(BuildContext context, String notify) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(notify, style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16
          )),
        );
      },
    );
  }

  Future<void> setAvailable(bool value) async
  {
    setState(() {
      is_available = value;
    });
    DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(user?.uid);
    await documentReference.update({
      'available': value,
    });
  }

  final List<String> testNames = [
    'Test 1',
    'Test 2',
    'Test 3',
    'Test 4',
    'Test 5'
  ];
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    String? name = user?.displayName;
    String? photoUrl = user?.photoURL;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF08FFB8), Color(0xFF5799F7)]),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: InkWell(
                        onTap: ()
                        {
                          Navigator.pop(context);
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF).withOpacity(0.24),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.arrow_back_ios, color: Colors.white),
                            )
                        ),
                      ),
                    ),
                  ],
                )
            ),
            const SizedBox(height: 10),
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
                                      child: Text(
                                          "Call & Practice English",
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
                  right: 4,
                  child: SizedBox(
                    height: 30,
                    width: 80,
                    child: TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const MeetingPage(is_expert: false,);
                          }));
                        },
                        child: const Row(
                          children: <Widget>[
                            Icon(Icons.call, size: 16, color: Color(0xFF2E56AF)),
                            Text("Call Now",
                                style:
                                TextStyle(color: Color(0xFF2E56AF), fontSize: 12))
                          ],
                        )),
                  ),
                )
              ]),
            ),
            const SizedBox(height: 10),
            Container(
              height: 162,
              width: 284,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF6B57F5),
                    Color(0xFF94EDFA),
                  ]
                )
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl!),
                    radius: 25,
                  ),
                  const SizedBox(height: 5.0),
                  Text(name!, style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  )),
                  const SizedBox(height: 25.0),
                  Container(
                    width: 190,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFFFAFA33).withOpacity(0.2)
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF1422A5)
                          ),
                          child: Center(
                            child: InkWell(
                              onTap: ()
                              {
                                _showDialog(context, "Now Co-learners will be able to connect with you.");
                                setAvailable(true);
                              },
                              child: const Text("Available", style: TextStyle(
                                color: Color(0xFFFDFDFD),
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                              )),
                            ),
                          )
                        ),
                        Center(
                          child: InkWell(
                            onTap: ()
                            {
                              _showDialog(context, "Now co-learners won't be able to connect with you.");
                              setAvailable(false);
                            },
                            child: const Text("Not Available", style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14
                            )),
                          ),
                        )
                      ],
                    )
                  )
                ],
              )
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                  child: Text("Test yourself", style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xB2000000)
                  ))),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: testNames.length,
              itemBuilder: (BuildContext context, int index) {
                return testTile(testNames[index]);
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      )
    );
  }
  Widget testTile(String testName)
  {
    return Card(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
                colors: [
                  Color(0xFFA1F8C0), Color(0xFF0BE3BC)
                ]
            )
        ),
        child: ListTile(
          title: Text(testName, style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15
          )),
          subtitle: const Text('10 Qs . 10 mins. 10 Marks', style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400
          )),
          trailing: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF1422A5)),
              ),
            onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return MeetingPage(is_expert: false,);
                }));
            },
            child: const Text('Take Test'),
          ),
        ),
      ),
    );
  }
}
