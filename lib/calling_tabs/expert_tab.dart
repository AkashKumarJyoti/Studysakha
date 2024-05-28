import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../call_page/call_page.dart';
import '../utils/term_and_condition.dart';

class ExpertTab extends StatelessWidget {
  const ExpertTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Container(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFF4739B), Color(0xFF35AFE4)])),
                    child: Row(
                      children: <Widget>[
                        Image.asset('images/graphics_expert.png'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Connect with Experts",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3.0),
                                    const Text(
                                        "Call & Practice English",
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                    const SizedBox(height: 3),
                                    Container(
                                        height: 23,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: const Color(0xFF000000).withOpacity(0.6),
                                          // color: Colors.black
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0, right: 6),
                                              child: Image.asset('images/noto_coin.png', height: 18),
                                            ),
                                            const Text("1 Coin / minute", style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white
                                            ))
                                          ],
                                        )
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                ),
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
                          backgroundColor: MaterialStateProperty.all(
                              Colors.white),
                        ),
                        onPressed: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return const MeetingPage(is_expert: true);
                            },
                          ));
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
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/2 - 35,
            child: ListView(
                children:[
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8),
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
