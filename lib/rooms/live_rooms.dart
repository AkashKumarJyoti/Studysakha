import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'live_class/call_screen.dart';

class LiveClass extends StatefulWidget {
  bool refresh;
  LiveClass({Key? key, required this.refresh}) : super(key: key);

  @override
  _LiveClassState createState() => _LiveClassState();
}

class _LiveClassState extends State<LiveClass> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 180,
      // color: Colors.black,
      margin: const EdgeInsets.only(top: 10, left: 15.1, right: 15),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('live_room').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text("No live classes");
          }

          List<DocumentSnapshot> liveClasses = [];

          for (var doc in snapshot.data!.docs) {
            DateTime classTime = (doc['time'] as Timestamp).toDate();
            if (classTime.isBefore(DateTime.now()) || classTime == DateTime.now()) {
              liveClasses.add(doc);
            }
          }

          return ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: liveClasses.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(top: 10.0),
                width: 331.72,
                height: 52.03,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3D73EB), Color(0xFFDE8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.134, 0.866],
                  ),
                  border: Border.all(
                    color: const Color(0xFF2664F599),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          '${liveClasses[index]['photoUrl']}',
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Topic: ${liveClasses[index]['topic']}',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        // From: Nisha Mondal
                        Text(
                          'From: ${liveClasses[index]['name']}',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 70.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CallStart(docId: liveClasses[index].id, roomUrl: liveClasses[index]['roomUrlListener'],)),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              const Text(
                                'Live',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    String formattedTime = DateFormat.jm().format(dateTime);
    String formattedDate = DateFormat('dd MMM').format(dateTime);

    return '$formattedTime, $formattedDate';
  }

}
