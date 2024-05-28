import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _razorpay = Razorpay();
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
    return Scaffold(

    );
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

}




