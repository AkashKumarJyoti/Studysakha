import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CoinOffers extends StatefulWidget {
  const CoinOffers({Key? key}) : super(key: key);

  @override
  State<CoinOffers> createState() => _CoinOffersState();
}

class _CoinOffersState extends State<CoinOffers> {
  final _razorpay = Razorpay();
  int value = 0;
  @override
  void initState() {
    // TODO: implement initState
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: ()
                    {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFF08FFB8),
                            Color(0xFF5799F7)
                          ]
                        )
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
                          child: Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                      )
                    ),
                  ),
                ),
                Text("Buy Coins", style: TextStyle(
                  color: const Color(0xFF000000).withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 22
                ),),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: coinsCount(),
                )
              ]
            ),
            const SizedBox(height: 25.0),
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  InkWell(onTap: ()
                      {
                        setState(() {
                          value = 1;
                        });
                        paymentInitiate(15);
                      },child: offerTile('images/buycoin/image 6.png', "50 coins", "₹15.00")),

                  InkWell(
                      onTap: ()
                      {
                        setState(() {
                          value = 2;
                        });
                        paymentInitiate(25);
                      },
                      child: offerTile('images/buycoin/image 8.png', "100 coins", "₹25.00")),

                  InkWell(
                      onTap: ()
                      {
                        setState(() {
                          value = 3;
                        });
                        paymentInitiate(45);
                      },
                      child: offerTile('images/buycoin/image 7.png', "200 coins", "₹45.00")),

                  InkWell(
                      onTap: ()
                      {
                        setState(() {
                          value = 4;
                        });
                        paymentInitiate(70);
                      },
                      child: offerTile('images/buycoin/image 9.png', "500 coins", "₹70.00")),

                  InkWell(
                      onTap: ()
                      {
                        setState(() {
                          value = 5;
                        });
                        paymentInitiate(80);
                      },
                      child: offerTile('images/buycoin/image 3.png', "600 coins", "₹80.00")),

                  InkWell(
                      onTap: ()
                      {
                        setState(() {
                          value = 6;
                        });
                        paymentInitiate(100);
                      },
                      child: offerTile('images/buycoin/image 5.png', "800 coins", "₹100.00")),

                  InkWell(
                      onTap: ()
                      {
                        setState(() {
                          value = 7;
                        });
                        paymentInitiate(160);
                      },
                      child: offerTile('images/buycoin/image 10.png', "1000 coins", "₹160.00")),

                  InkWell(
                      onTap: ()
                      {
                        setState(() {
                          value = 8;
                        });
                        paymentInitiate(200);
                      },
                      child: offerTile('images/buycoin/image 4.png', "2000 coins", "₹200.00")),
                ],
              )
            ),
          ]
        )
      ),
    );
  }

  void paymentInitiate(int amount)
  {
    var options = {
      'key': 'rzp_test_GqBW8xGvT6hpIi',
      'amount': amount*100,
      'name': 'Akash',
      'description': 'Add Coin',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': false,
      'prefill': {'contact': '6202653995', 'email': 'test@razorpay.com'},
    };
    _razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response){
    print("Payment Error: ${response.code} - ${response.message}");
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
    _razorpay.clear();
  }

  Future<void> handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    var uid = FirebaseAuth.instance.currentUser?.uid;
    int coinCount = 0;

    try {
      var snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        setState(() {
          coinCount = snapshot.data()?['coins'];
        });
        coinCount = snapshot.data()?['coins'];
        print('Coin count: $coinCount');
      } else {
        print('Document does not exist');
      }

      print("Payment response: ${response.paymentId} ${response.orderId} ${response.signature}");
      if(value == 1) {
        setState(() {
          coinCount = coinCount + 50;
        });
      } else if(value == 2) {
        setState(() {
          coinCount = coinCount + 100;
        });
      } else if(value == 3) {
        setState(() {
          coinCount = coinCount + 200;
        });
      } else if(value == 4) {
        setState(() {
          coinCount = coinCount + 500;
        });
      } else if(value == 5) {
        setState(() {
          coinCount = coinCount + 600;
        });
      } else if(value == 6) {
        setState(() {
          coinCount = coinCount + 800;
        });
      } else if(value == 7) {
        setState(() {
          coinCount = coinCount + 1000;
        });
      } else if(value == 8) {
        setState(() {
          coinCount = coinCount + 2000;
        });
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'coins': coinCount,
      });

      showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");
    } catch (error) {
      print('Error retrieving or updating document: $error');
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response){
    showAlertDialog(context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message){
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed:  () {
        // TODO Navigate to out of the payment screen
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget offerTile(String imgUrl, String coinCount, String coinAmount)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF69E5A9)
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset(imgUrl),
                  ),
                ),
              ),
              const SizedBox(width: 5.0),
              Text(coinCount, style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600
              )),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(right: 18.0),
                child: CrossedTextWidget(
                  text: '₹50',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Text(coinAmount, style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500
                )),
              )
            ],
          )
      ),
    );
  }

  Widget coinsCount() {
    User? user = FirebaseAuth.instance.currentUser;
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
                    style: const TextStyle(color: Color(0xFF0BE3BC)),
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

class CrossedTextWidget extends StatelessWidget {
  final String text;

  const CrossedTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
        ),
        Positioned(
          top: 8,
          left: 0,
          child: Container(
            height: 2,
            width: 50,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
