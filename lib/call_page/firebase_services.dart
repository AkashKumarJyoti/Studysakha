import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import '../api_calls/management_token.dart';
import '../api_calls/room_create.dart';

class FireBaseServices {
  static late QuerySnapshot _querySnapshot;
  static final _db = FirebaseFirestore.instance;

  static getRoomsExpert(HMSSDK hmssdk) async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    String token = generateToken();
    String? roomUrl = await RoomService.createRoom(token, name!, true, hmssdk);
      _querySnapshot = await _db
          .collection('expert_rooms')
          .where('users', isEqualTo: 0)
          .limit(1)
          .get();

    await _db
        .collection('expert_rooms')
        .doc(_querySnapshot.docs[0].id)
        .update({'users': FieldValue.increment(1)});
    return _querySnapshot;
  }

  static getRooms() async {
    _querySnapshot = await _db
        .collection('user_rooms')
        .where('users', isEqualTo: 1)
        .limit(1)
        .get();

    if(_querySnapshot.docs.isEmpty) {
      _querySnapshot = await _db
          .collection('user_rooms')
          .where('users', isEqualTo: 0)
          .limit(1)
          .get();
    }

    if (_querySnapshot.docs.isNotEmpty) {
      await _db
          .collection('user_rooms')
          .doc(_querySnapshot.docs[0].id)
          .update({'users': FieldValue.increment(1)});
    }
    return _querySnapshot;
  }

  static leaveRoom() async {
    String roomId = _querySnapshot.docs[0].id;
    int userCount = 0;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('user_rooms').doc(roomId).get();
    userCount = documentSnapshot['users'];
    if(userCount == 1) {
      String token = generateToken();
      String apiUrl = 'https://api.100ms.live/v2/rooms/$roomId';
      Map<String, dynamic> requestBody = {
        "enabled": false,
      };
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> roomInfo = json.decode(response.body);
        } else {
          print('Failed to get room info. Status code: ${response.statusCode}');
        }
      }catch (error) {
        print('Error: $error');
      }

      await _db.collection('user_rooms').doc(roomId).delete();
    }
    else if(userCount == 2) {
      await _db
          .collection('user_rooms')
          .doc(_querySnapshot.docs[0].id)
          .update({'users': FieldValue.increment(-1)});
    }
  }

  static leaveRoomExpert() async {
    String roomId = _querySnapshot.docs[0].id;
    int userCount = 0;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('expert_rooms').doc(roomId).get();
    userCount = documentSnapshot['users'];
    if(userCount == 2) {
      await _db
          .collection('expert_rooms')
          .doc(_querySnapshot.docs[0].id)
          .update({'users': FieldValue.increment(-1)});
    }
    else if(userCount == 1) {
      String token = generateToken();
      String apiUrl = 'https://api.100ms.live/v2/rooms/$roomId';
      Map<String, dynamic> requestBody = {
        "enabled": false,
      };
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> roomInfo = json.decode(response.body);
        } else {
          print('Failed to get room info. Status code: ${response.statusCode}');
        }
      }catch (error) {
        print('Error: $error');
      }
      await _db.collection('expert_rooms').doc(roomId).delete();
    }

  }
}