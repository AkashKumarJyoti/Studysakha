import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:io';

class AccessTokenFirebase {
  static const String firebaseMessagingScope = "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getAccessToken() async {
    try {
      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(dotenv.env['FIREBASE_SERVICE_ACCOUNT_KEY']),
        [firebaseMessagingScope],
      );

      final accessToken = client.credentials.accessToken.data;
      print("Access Token: $accessToken");
      return accessToken;
    } catch (e) {
      print("Error obtaining access token: $e");
      rethrow;
    }
  }
}
