import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:studysakha_calling/payment_gateway/coin_offer.dart';
import '../calling_tabs/call_history_tab.dart';
import '../calling_tabs/co_learner_tab.dart';
import '../calling_tabs/expert_tab.dart';
import '../sidemenubar.dart';

class CallHomePage extends StatefulWidget {
  const CallHomePage({Key? key}) : super(key: key);

  @override
  State<CallHomePage> createState() => _CallHomePageState();
}

class _CallHomePageState extends State<CallHomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // This will make the status bar transparent
    ));
  }

  var current_index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
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
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 15.0),
                  InkWell(
                    onTap: ()
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SideMenuScreen()));
                    },
                      child: Image.asset('images/menu_icon.png')),
                  const SizedBox(width: 15.0),
                  InkWell(
                    onTap: ()
                    async {
                      await GoogleSignIn().disconnect();
                              FirebaseAuth.instance.signOut();

                    },
                    child: const Text(
                      "Call",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
                          color: Color(0xFFFFFFFF)),
                    ),
                  ),
                  const Spacer(),
                  current_index == 1 ? Padding(
                    padding: const EdgeInsets.only(right: 28.0),
                    child: Row(
                      children: <Widget>[
                        coinsCount(),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: ()
                          {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const CoinOffers())
                            );
                          },
                            child: const Icon(Icons.add_box, color: Colors.white))
                      ],
                    ),
                  ) : Container(),
                ],
              ),
            )),
        const SizedBox(height: 25.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    current_index = 0;
                  });
                },
                child: Container(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width / 3 - 10,
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0BBEB4)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        gradient: current_index == 0
                            ? const LinearGradient(
                                colors: [Color(0xFF0BBEB4), Color(0xFF33B3DB)])
                            : const LinearGradient(
                                colors: [Colors.white, Colors.white])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Call With",
                            style: TextStyle(
                                color: current_index == 0
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                        // SizedBox(height: 1),
                        Text("Co-Learners",
                            style: TextStyle(
                                color: current_index == 0
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 14))
                      ],
                    )),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    current_index = 1;
                  });
                },
                child: Container(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width / 3 - 10,
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0BBEB4)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        gradient: current_index == 1
                            ? const LinearGradient(
                                colors: [Color(0xFF0BBEB4), Color(0xFF33B3DB)])
                            : const LinearGradient(
                                colors: [Colors.white, Colors.white])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Call With",
                            style: TextStyle(
                                color: current_index == 1
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                        Text("Expert",
                            style: TextStyle(
                                color: current_index == 1
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 14))
                      ],
                    )),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    current_index = 2;
                  });
                },
                child: Container(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width / 3 - 10,
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0BBEB4)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        gradient: current_index == 2
                            ? const LinearGradient(
                                colors: [Color(0xFF0BBEB4), Color(0xFF33B3DB)])
                            : const LinearGradient(
                                colors: [Colors.white, Colors.white])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Call History",
                            style: TextStyle(
                                color: current_index == 2
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                      ],
                    )),
              )
            ],
          ),
        ),
        const SizedBox(height: 15.0),
        current_index == 0 ? const CoLearnerTab() : current_index == 1 ? const ExpertTab() : const TabBarExample()
      ],
    ));
  }

  Widget coinsCount() {
    User? user = FirebaseAuth.instance.currentUser;
    print("User id: ${user?.uid}");
    DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(user?.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: documentReference.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            var coinCount = snapshot.data!['coins'];
            return Container(
              height: 31,
              width: 73,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: const Color(0xFFEFB71C)),
              ),
              child: Row(
                children: [
                  Image.asset('images/noto_coin.png'),
                  Text(
                    coinCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          } else {
            return const Text("Error");
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

}
