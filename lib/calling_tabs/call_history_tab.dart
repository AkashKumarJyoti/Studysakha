import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabBarExample extends StatelessWidget {
  const TabBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height-310,
      child: const DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor:
              Colors.black,
              indicatorColor: Color(0xFF2C69F5),
              tabs: <Widget>[
                Tab(
                  text: 'Co-learner',
                ),
                Tab(
                  text: 'Expert',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  Center(
                    child: CoLearnersTab(),
                  ),
                  Center(
                    child: ExpertsTab(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoLearnersTab extends StatelessWidget {
  const CoLearnersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CoLearnerCallHistoryList();
  }
}

class ExpertsTab extends StatelessWidget {
  const ExpertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpertCallHistoryList();
  }
}

class ExpertCallHistoryList extends StatefulWidget {
  const ExpertCallHistoryList({super.key});

  @override
  _ExpertCallHistoryListState createState() => _ExpertCallHistoryListState();
}

class _ExpertCallHistoryListState extends State<ExpertCallHistoryList> {
  DocumentReference userDocRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: userDocRef.collection('expert_history').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> callHistoryDocs = snapshot.data!.docs;

            List<Widget> callHistoryWidgets = callHistoryDocs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String expertName = data['expert_name'];
              String duration = data['duration'].toString();
              String photoUrl = data['photoUrl'].toString();

              return callDetails(expertName, duration, photoUrl);
            }).toList();

            return Column(
              children: callHistoryWidgets,
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Text("Expert content");
          }
        },
      ),
    );
  }

  Widget callDetails(String name, String duration, String photoUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: DecorationImage(
                    image: NetworkImage(photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Span: $duration mins",
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
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

class CoLearnerCallHistoryList extends StatefulWidget {
  const CoLearnerCallHistoryList({Key? key}) : super(key: key);

  @override
  State<CoLearnerCallHistoryList> createState() => _CoLearnerCallHistoryListState();
}

class _CoLearnerCallHistoryListState extends State<CoLearnerCallHistoryList> {
  DocumentReference userDocRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: userDocRef.collection('colearner_history').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> callHistoryDocs = snapshot.data!.docs;

            List<Widget> callHistoryWidgets = callHistoryDocs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String coLearnerName = data['colearner_name'];
              String duration = data['duration'].toString();
              return callDetails(coLearnerName, duration);
            }).toList();

            return Column(
              children: callHistoryWidgets,
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Text("Co-learner content");
          }
        },
      ),
    );
  }
  Widget callDetails(String name, String duration) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              // child: Container(
              //   height: 45,
              //   width: 45,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(5.0),
              //     image: DecorationImage(
              //       image: NetworkImage(photoUrl),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}