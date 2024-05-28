import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:studysakha_calling/api_calls/management_token.dart';
import 'package:studysakha_calling/api_calls/room_create.dart';
import 'access_firebase_token.dart';
import 'firebase_services.dart';
import 'package:http/http.dart' as http;

class JoinService {

  //Function to get roomId stored in Firebase
  static Future<QuerySnapshot?> getRoom(bool is_expert, HMSSDK hmssdk) async {
    QuerySnapshot? _result;
    is_expert ? await FireBaseServices.getRoomsExpert(hmssdk).then((data) {
      _result = data;
    }) : await FireBaseServices.getRooms().then((data){
      _result = data;
    });
    return _result;
  }

  static Future<QuerySnapshot?> join(HMSSDK hmssdk, bool is_expert) async {
    QuerySnapshot? _result = await getRoom(is_expert, hmssdk);
    String name = FirebaseAuth.instance.currentUser?.displayName ?? " ";
    String? roomUrl;
    String? roomId;

    if(_result != null && _result.docs.isNotEmpty)
    {
      roomUrl = _result.docs[0].get('roomUrl');
      roomId = _result.docs[0].id;
      if(is_expert == true) {
        CollectionReference experts = FirebaseFirestore.instance.collection('experts');
        QuerySnapshot querySnapshot = await experts.where('available', isEqualTo: true).limit(1).get();
        if(querySnapshot.docs.isNotEmpty)
        {
          String availableExpertToken = querySnapshot.docs.first['message_token'].toString();
          sendPushNotification(roomUrl!, roomId, availableExpertToken);
        }
      }
    }
    else {
      String token = generateToken();
      roomUrl = await RoomService.createRoom(token, name, is_expert, hmssdk);
      _result = await getRoom(is_expert, hmssdk);
    }

    HMSConfig config = HMSConfig(authToken: roomUrl!, userName: name);
    await hmssdk.join(config: config);
    return _result;
  }

  static Future<void> sendPushNotification(String roomUrl, String roomId, String messageToken) async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    String? currentUserDocId = FirebaseAuth.instance.currentUser?.uid;
    final fcmToken = await FirebaseMessaging.instance.getToken();   // User message-token

    AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
    String token = await accessTokenGetter.getAccessToken();
    const String postUrl = 'https://fcm.googleapis.com/v1/projects/studysakha-65319/messages:send';

    final Map<String, dynamic> notificationData = {
      'message': {
        'notification': {
          'body': 'Incoming Call',
          'title': name,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'token': roomUrl,
          'roomId': roomId,
          'message_token': fcmToken,
          'docId': currentUserDocId,
        },
        'android': {
          'priority': 'high',
        },
        'token': messageToken,
      },
    };

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(postUrl),
      headers: headers,
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  static Future<String> roomCode(String roomId, String token) async {
    String roomCodeUrl = 'https://api.100ms.live/v2/room-codes/room/$roomId/role/speaker';

    try {
      final response = await http.post(
        Uri.parse(roomCodeUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> roomInfo = json.decode(response.body);
        String roomCode = roomInfo['code'];
        return roomCode;
      } else {
        // Handle unsuccessful request
        print('Failed to generate Room Code. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to generate Room Code');
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
      throw Exception('An error occurred while generating Room Code');
    }
  }
}