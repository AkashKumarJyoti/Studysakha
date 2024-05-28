import 'dart:convert';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  static Future<String?> createRoom(String token, String name, bool isExpert, HMSSDK hmssdk) async {
    String apiUrl = 'https://api.100ms.live/v2/rooms?template_id=6546890745b44708fd4131f9&template=AR-quiet-sea-788903';
    Map<String, dynamic> requestBody = {
      "description": "This is a sample description for the room",
      "template_id": "6546890745b44708fd4131f9",
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

        String roomId = roomInfo['id'];
        String rCode = await roomCode(roomId, token);
        print(rCode);

        String roomUrl = await hmssdk.getAuthTokenByRoomCode(roomCode: rCode);

        if(isExpert == false) {
          DocumentReference documentReference = FirebaseFirestore.instance.collection('user_rooms').doc(roomId);
          await documentReference.set({
            'roomUrl': roomUrl,
            'users': 0,
            'name': name,
          });
        }
        else {
          DocumentReference documentReference = FirebaseFirestore.instance.collection('expert_rooms').doc(roomId);
          await documentReference.set({
            'roomUrl': roomUrl,
            'users': 0,
            'name': name,
            'quizAvailable': false
          });
        }
        return roomUrl;
      } else {
        print('Failed to get room info. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    return null;
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



