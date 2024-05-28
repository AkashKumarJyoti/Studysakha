import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'duration_formatter.dart';
import 'firebase_services.dart';
import 'join_services.dart';

class MeetingPage extends StatefulWidget {
  final bool is_expert;
  const MeetingPage({super.key, required this.is_expert});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> with WidgetsBindingObserver
    implements HMSUpdateListener, HMSActionResultListener {
  late HMSSDK _hmsSDK;

  Offset position = const Offset(5, 5);
  bool isJoinSuccessful = false;
  final List<PeerTrackNode> _listeners = [];
  final List<PeerTrackNode> _speakers = [];
  bool _isMicrophoneMuted = false;
  bool _isLoading = false;
  QuerySnapshot? _result = null;
  HMSPeer? _localPeer;
  AppLifecycleState? _notification;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool quizAvailable = false;
  String questions = "";
  String opt1 = "";
  String opt2 = "";
  String opt3 = "";
  String opt4 = "";
  String correctOption = "0";

  String op1 = "-1";
  String op2 = "-1";
  String op3 = "-1";
  String op4 = "-1";

  void listenForFCMMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.data.isNotEmpty) {
        setState(() {
          quizAvailable = true;
          questions = message.data['question'];
          opt1 = message.data['op1'];
          opt2 = message.data['op2'];
          opt3 = message.data['op3'];
          opt4 = message.data['op4'];
          correctOption = message.data['correct_option'];
        });
      }
    });
  }

  void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        dispose();
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        dispose();
        break;
      default:
        print("Default");
    }
  }

  bool is_available = true;

  Future<bool> joinRoom() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot? temp = await JoinService.join(_hmsSDK, widget.is_expert);

    if (widget.is_expert) {
      CollectionReference experts = FirebaseFirestore.instance.collection(
          'experts');
      QuerySnapshot querySnapshot = await experts.where(
          'available', isEqualTo: true).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          is_available = true;
        });
      }
      else {
        setState(() {
          is_available = false;
        });
      }
    }

    setState(() {
      _result = temp;
    });
    bool isJoinSuccessful = (_result != null) ? true : false;
    if (!isJoinSuccessful) {
      return false;
    }
    _hmsSDK.addUpdateListener(listener: this);
    setState(() {
      _isLoading = false;
    });
    return true;
  }

  late DateTime callStartTime;
  late StreamController<DateTime> timerStreamController;
  late Stream<DateTime> timerStream;

  @override
  void initState() {
    super.initState();
    getPermissions();
    initHMSSDK();
    callStartTime = DateTime.now();
    timerStreamController = StreamController<DateTime>();
    timerStream = timerStreamController.stream;
    listenForFCMMessages();
    // Periodically update the stream
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final currentTime = DateTime.now();
      final callDuration = currentTime.difference(callStartTime);
      timerStreamController.add(currentTime);
    });
    WidgetsBinding.instance.addObserver(this);
  }

//To know more about HMSSDK setup and initialization checkout the docs here: https://www.100ms.live/docs/flutter/v2/how--to-guides/install-the-sdk/hmssdk
  void initHMSSDK() async {
    _hmsSDK = HMSSDK();
    await _hmsSDK.build();
    joinRoom();
  }

  @override
  void dispose() {
    //We are clearing the room state here
    _speakers.clear();
    _listeners.clear();
    timerStreamController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  bool flag = true;
  Future<void> accessSpeakerNames() async {
    for (var speakerNode in _speakers) {
      String speakerName = speakerNode.peer.name;
      String userName = FirebaseAuth.instance.currentUser?.displayName ?? "";
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      if(userName != speakerName && flag == true)
      {
        var collectionReference = FirebaseFirestore.instance.collection('users').doc(uid).collection('colearner_history');

        await collectionReference.doc(uid).set(
          {
            'colearner_name': speakerName,
          },
        );
        setState(() {
          flag = false;
        });
      }
      print("Speaker Name: $speakerName");
    }
  }

  //Here we will be getting updates about peer join, leave, role changed, name changed etc.
  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (peer.isLocal) {
      _localPeer = peer;
    }
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            } else {
              _speakers.add(PeerTrackNode(
                uid: "${peer.peerId}speaker",
                peer: peer,
              ));
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            } else {
              _listeners.add(
                  PeerTrackNode(uid: "${peer.peerId}listener", peer: peer));
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.peerLeft:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers.removeAt(index);
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners.removeAt(index);
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.roleUpdated:
        if (peer.role.name == "speaker") {
          //This means previously the user must be a listener earlier in our case
          //So we remove the peer from listener and add it to speaker list
          int index = _listeners
              .indexWhere((node) => node.uid == "${peer.peerId}listener");
          if (index != -1) {
            _listeners.removeAt(index);
          }
          _speakers.add(PeerTrackNode(
            uid: "${peer.peerId}speaker",
            peer: peer,
          ));
          if (peer.isLocal) {
            _isMicrophoneMuted = peer.audioTrack?.isMute ?? true;
          }
          setState(() {});
        } else if (peer.role.name == "listener") {
          //This means previously the user must be a speaker earlier in our case
          //So we remove the peer from speaker and add it to listener list
          int index = _speakers
              .indexWhere((node) => node.uid == "${peer.peerId}speaker");
          if (index != -1) {
            _speakers.removeAt(index);
          }
          _listeners.add(PeerTrackNode(
            uid: "${peer.peerId}listener",
            peer: peer,
          ));
          setState(() {});
        }
        break;
      case HMSPeerUpdate.metadataChanged:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.nameChanged:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.defaultUpdate:
      // TODO: Handle this case.
        break;
      case HMSPeerUpdate.networkQualityUpdated:
      // TODO: Handle this case.
        break;
      default:
        break;
    }
  }

  @override
  void onTrackUpdate({required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer}) {
    switch (peer.role.name) {
      case "speaker":
        int index =
        _speakers.indexWhere((node) => node.uid == "${peer.peerId}speaker");
        if (index != -1) {
          _speakers[index].audioTrack = track;
        } else {
          _speakers.add(PeerTrackNode(
              uid: "${peer.peerId}speaker", peer: peer, audioTrack: track));
        }
        if (peer.isLocal) {
          _isMicrophoneMuted = track.isMute;
        }
        setState(() {});
        break;
      case "listener":
        int index = _listeners
            .indexWhere((node) => node.uid == "${peer.peerId}listener");
        if (index != -1) {
          _listeners[index].audioTrack = track;
        } else {
          _listeners.add(PeerTrackNode(
              uid: "${peer.peerId}listener", peer: peer, audioTrack: track));
        }
        setState(() {});
        break;
      default:
      //Handle the case if you have other roles in the room
        break;
    }
  }

  @override
  void onJoin({required HMSRoom room}) {
    //Checkout the docs about handling onJoin here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/join#join-a-room
    room.peers?.forEach((peer) {
      if (peer.isLocal) {
        _localPeer = peer;
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            } else {
              _speakers.add(PeerTrackNode(
                uid: "${peer.peerId}speaker",
                peer: peer,
              ));
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            } else {
              _listeners.add(
                  PeerTrackNode(uid: "${peer.peerId}listener", peer: peer));
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
      }
    });
  }

  bool speaker = false;

  @override
  void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice}) {
    _hmsSDK.switchAudioOutput(
        audioDevice: speaker ? HMSAudioDevice.SPEAKER_PHONE : HMSAudioDevice
            .EARPIECE);
    // currentAudioDevice : audio device to which audio is curently being routed to
    // availableAudioDevice : all other available audio devices
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    // Checkout the docs for handling the unmute request here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/track/remote-mute-unmute
  }

  @override
  void onHMSError({required HMSException error}) {
    // To know more about handling errors please checkout the docs here: https://www.100ms.live/docs/flutter/v2/how--to-guides/debugging/error-handling
  }

  @override
  void onMessage({required HMSMessage message}) {
    // Checkout the docs for chat messaging here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/chat
  }

  @override
  void onReconnected() {
    // Checkout the docs for reconnection handling here: https://www.100ms.live/docs/flutter/v2/how--to-guides/handle-interruptions/reconnection-handling
  }

  @override
  void onReconnecting() {
    // Checkout the docs for reconnection handling here: https://www.100ms.live/docs/flutter/v2/how--to-guides/handle-interruptions/reconnection-handling
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    // Checkout the docs for handling the peer removal here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/peer/remove-peer
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    // Checkout the docs for handling the role change request here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/peer/change-role#accept-role-change-request
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    // Checkout the docs for room updates here: https://www.100ms.live/docs/flutter/v2/how--to-guides/listen-to-room-updates/update-listeners
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    // Checkout the docs for handling the updates regarding who is currently speaking here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/render-video/show-audio-level
  }

  /// ******************************************************************************************************************************************************
  /// Action result listener methods

  @override
  void onException({required HMSActionResultListenerMethod methodType,
    Map<String, dynamic>? arguments,
    required HMSException hmsException}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        log("Not able to leave error occured");
        break;
      default:
        break;
    }
  }

  @override
  void onSuccess({required HMSActionResultListenerMethod methodType,
    Map<String, dynamic>? arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        _hmsSDK.removeUpdateListener(listener: this);
        _hmsSDK.destroy();
        break;
      default:
        break;
    }
  }

  /// ******************************************************************************************************************************************************
  /// Functions

  final List<Color> _colors = [
    Colors.amber,
    Colors.blue.shade600,
    Colors.purple,
    Colors.lightGreen,
    Colors.redAccent
  ];

  final RegExp _REGEX_EMOJI = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  String _getAvatarTitle(String name) {
    if (name.contains(_REGEX_EMOJI)) {
      name = name.replaceAll(_REGEX_EMOJI, '');
      if (name
          .trim()
          .isEmpty) {
        return '😄';
      }
    }
    List<String>? parts = name.trim().split(" ");
    if (parts.length == 1) {
      name = parts[0][0];
    } else if (parts.length >= 2) {
      name = parts[0][0];
      if (parts[1] == "" || parts[1] == " ") {
        name += parts[0][1];
      } else {
        name += parts[1][0];
      }
    }
    return name.toUpperCase();
  }

  Color _getBackgroundColour(String name) {
    if (name.isEmpty) return Colors.blue.shade600;
    if (name.contains(_REGEX_EMOJI)) {
      name = name.replaceAll(_REGEX_EMOJI, '');
      if (name
          .trim()
          .isEmpty) {
        return Colors.blue.shade600;
      }
    }
    return _colors[name.toUpperCase().codeUnitAt(0) % _colors.length];
  }

  Future<bool> leaveRoom() async {
    _hmsSDK.leave(hmsActionResultListener: this);
    final currentTime = DateTime.now();
    final callDuration = currentTime.difference(callStartTime);
    int durationInMinutes = callDuration.inSeconds;
    var uid = FirebaseAuth.instance.currentUser?.uid;

    if (widget.is_expert) {
      FireBaseServices.leaveRoomExpert();
    } else {
      FireBaseServices.leaveRoom();
    }
    Navigator.pop(context);
    return false;
  }



  @override
  Widget build(BuildContext context) {
    accessSpeakerNames();
    return StreamBuilder(
      stream: widget.is_expert
          ? FirebaseFirestore.instance.collection('expert_rooms').doc(
          _result?.docs[0].id).snapshots()
          : FirebaseFirestore.instance.collection('user_rooms').doc(
          _result?.docs[0].id).snapshots(),
      builder: (context, snapshot) {
        try {
          if (snapshot.hasData) {
            return WillPopScope(
              onWillPop: () async {
                return leaveRoom();
              },
              child: Scaffold(
                body: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : snapshot.data?['users'] < 2
                    ? noPeerScreen()
                    : widget.is_expert
                    ? callUiExpert()
                    : callUiColearner(),
              ),
            );
          } else if (snapshot.hasError) {
            // Handle the error here
            print("Error: ${snapshot.error}");
            return const Center(
              child: Text(""),
            );
          } else {
            return const Center(
              child: Text(""),
            );
          }
        } catch (error) {
          print("Catch error: $error");
          return const Text("");
        }
      },
    );
  }


  @override
  void onPeerListUpdate({required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers}) {
    // TODO: implement onPeerListUpdate
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // TODO: implement onSessionStoreAvailable
  }

  Widget noPeerScreen() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(is_available == true
                ? "You're the only one here"
                : "No expert is available", style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w800
            )),
            const SizedBox(height: 15),
            Text(is_available ? widget.is_expert
                ? "Please wait for our expert to join"
                : "Please wait for the Peers to join"
                : "Please try again later",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),),
          ],
        ),
      ),
    );
  }

  Widget callUiExpert()
  {
    return StreamBuilder<int>(
      stream: getCoinsStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          int coins = snapshot.data!;
          if(coins == 0) {
            Future.delayed(Duration.zero, () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Coins Depleted'),
                    content: const Text('You have run out of coins.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            });
            FireBaseServices.leaveRoomExpert();
            _hmsSDK.leave(hmsActionResultListener: this);
            Navigator.pop(context);
            return const Text("");
          }
          else {
            return Column(
              children: [
                Expanded(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 50),
                          CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                'images/ic_user.png',
                                fit: BoxFit.cover,
                              )),
                          StreamBuilder<DateTime>(
                            stream: timerStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final currentTime = snapshot.data;
                                final callDuration =
                                currentTime?.difference(callStartTime);
                                final formattedDuration =
                                DurationFormatter.format(callDuration!);
                                return Text(
                                  formattedDuration,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                );
                              } else {
                                return const Text(
                                  '00:00',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          const Text("In a call",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          StreamBuilder<bool>(
                              stream: isQuizAvailable(),
                              builder: (context, snapshot) {
                                if(snapshot.hasData) {
                                  bool quizAvailability = snapshot.data!;
                                  if(quizAvailability == true) {
                                    return Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            const Text("Q. ", style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0
                                            ),),
                                            Expanded(
                                              child: Text(questions, style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0
                                              )),
                                            )
                                          ],
                                        ),
                                        // Options of the quiz.
                                        InkWell(
                                          onTap: ()
                                          async {
                                            setState(() {
                                              correctOption == "1" ? op1 = "1" : op1 = "5";
                                            });
                                            if(correctOption == op1) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Correct answer', style: TextStyle(color: Colors.white)),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                            else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Wrong answer', style: TextStyle(color: Colors.white)),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            await Future.delayed(const Duration(seconds: 2));
                                            FirebaseFirestore.instance.collection('expert_rooms').doc(_result?.docs[0].id).update({
                                              'quizAvailable': false
                                            });
                                            setState(() {
                                              correctOption = "0";
                                              op1 = "-1";
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 43,
                                              width: 335,
                                              decoration: BoxDecoration(
                                                color: op1 == "-1" ? Colors.white : op1 == "1" ? const Color(0xFF08C955) : const Color(0xFFE91D42),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Text(opt1, style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14
                                                    )),
                                                  )),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: ()
                                          async {
                                            setState(() {
                                              correctOption == "2" ? op2 = "2" : op2 = "5";
                                            });
                                            if(correctOption == op2) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Correct answer', style: TextStyle(color: Colors.white)),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                            else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Wrong answer', style: TextStyle(color: Colors.white)),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            await Future.delayed(const Duration(seconds: 2));
                                            FirebaseFirestore.instance.collection('expert_rooms').doc(_result?.docs[0].id).update({
                                              'quizAvailable': false
                                            });
                                            setState(() {
                                              correctOption = "0";
                                              op2 = "-1";
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 43,
                                              width: 335,
                                              decoration: BoxDecoration(
                                                color: op2 == "-1" ? Colors.white : op2 == "2" ? const Color(0xFF08C955) : const Color(0xFFE91D42),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Text(opt2, style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14
                                                    ),),
                                                  )),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: ()
                                          async {
                                            setState(() {
                                              correctOption == "3" ? op3 = "3" : op3 = "5";
                                            });
                                            if(correctOption == op3) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Correct answer', style: TextStyle(color: Colors.white)),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                            else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Wrong answer', style: TextStyle(color: Colors.white)),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            await Future.delayed(const Duration(seconds: 2));
                                            FirebaseFirestore.instance.collection('expert_rooms').doc(_result?.docs[0].id).update({
                                              'quizAvailable': false
                                            });
                                            setState(() {
                                              correctOption = "0";
                                              op3 = "-1";
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 43,
                                              width: 335,
                                              decoration: BoxDecoration(
                                                color: op3 == "-1" ? Colors.white : op3 == "3" ? const Color(0xFF08C955) : const Color(0xFFE91D42),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Text(opt3, style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14
                                                    )),
                                                  )),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: ()
                                          async {
                                            setState(() {
                                              correctOption == "4" ? op4 = "4" : op4 = "5";
                                            });
                                            if(correctOption == op4) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Correct answer', style: TextStyle(color: Colors.white)),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                            else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Wrong answer', style: TextStyle(color: Colors.white)),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            await Future.delayed(const Duration(seconds: 2));
                                            FirebaseFirestore.instance.collection('expert_rooms').doc(_result?.docs[0].id).update({
                                              'quizAvailable': false
                                            });
                                            setState(() {
                                              correctOption = "0";
                                              op4 = "-1";
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 43,
                                              width: 335,
                                              decoration: BoxDecoration(
                                                color: op4 == "-1" ? Colors.white : op4 == "4" ? const Color(0xFF08C955) : const Color(0xFFE91D42),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Text(opt4, style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14
                                                    )),
                                                  )),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  }
                                  else {
                                    return const Text("Ask For the quiz", style: TextStyle(color: Colors.white),);
                                  }
                                }
                                else {
                                  return const Text("");
                                }
                              }),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                  onTap: ()
                                  {
                                    setState(() {
                                      speaker = !speaker;
                                    });
                                    onAudioDeviceChanged();
                                  },
                                  child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Icon(speaker ? Icons.volume_up : Icons.volume_down, color: Colors.white, size: 45)
                                  )
                              ),
                              InkWell(
                                onTap: () {
                                  onAudioDeviceChanged();
                                  setState(() {
                                    _isMicrophoneMuted = !_isMicrophoneMuted;
                                  });
                                },
                                child: Icon(
                                  _isMicrophoneMuted
                                      ? Icons.mic_off
                                      : Icons.mic,
                                  color: _isMicrophoneMuted
                                      ? Colors.white
                                      : Colors.white,
                                  size: 45,
                                ),
                              ),
                              InkWell(
                                onTap: ()
                                {
                                  FireBaseServices.leaveRoomExpert();
                                  _hmsSDK.leave(hmsActionResultListener: this);
                                  Navigator.pop(context);
                                },
                                child: const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFFE91D42),
                                  child: Icon(Icons.call_end, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35.0),
                        ],
                      )),
                ),
              ],
            );
          }
        }
        else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return const CircularProgressIndicator();
        }

      }
    );
  }

  Stream<bool> isQuizAvailable() {
    var docId = FirebaseAuth.instance.currentUser?.uid;
    var roomId = _result?.docs[0].id;
    return FirebaseFirestore.instance
        .collection('expert_rooms')
        .doc(roomId)
        .snapshots()
        .map((snapshot) => snapshot['quizAvailable'] ?? 0);
  }

  Stream<int> getCoinsStream() {
    var docId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(docId)
        .snapshots()
        .map((snapshot) => snapshot['coins'] ?? 0);
  }
  // bool flag2 = true;
  Widget callUiColearner()
  {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF08FFB8), Color(0xFF5799F7)])),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 50),
                  CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        'images/ic_user.png',
                        fit: BoxFit.cover,
                      )),
                  StreamBuilder<DateTime>(
                    stream: timerStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final currentTime = snapshot.data;
                        final callDuration =
                        currentTime?.difference(callStartTime);
                        final formattedDuration =
                        DurationFormatter.format(callDuration!);
                        return Text(
                          formattedDuration,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        );
                      } else {
                        return const Text(
                          '00:00',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text("In a call",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              )),
          Expanded(
            child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                            onTap: ()
                            {
                              setState(() {
                                speaker = !speaker;
                              });
                              onAudioDeviceChanged();
                            },
                            child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Icon(speaker ? Icons.volume_up : Icons.volume_down, color: Colors.black)
                            )
                        ),
                        InkWell(
                          onTap: () {
                            onAudioDeviceChanged();
                            setState(() {
                              _isMicrophoneMuted = !_isMicrophoneMuted;
                            });
                          },
                          child: Icon(
                            _isMicrophoneMuted
                                ? Icons.mic_off
                                : Icons.mic,
                            color: _isMicrophoneMuted
                                ? Colors.black
                                : Colors.black,
                            size: 35,
                          ),
                        ),
                        InkWell(
                          onTap: ()
                          {
                            _hmsSDK.leave(hmsActionResultListener: this);
                            FireBaseServices.leaveRoom();
                            Navigator.pop(context);
                          },
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFFE91D42),
                            child: Icon(Icons.call_end, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0)
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class PeerTrackNode {
  String uid;
  HMSPeer peer;
  bool isRaiseHand;
  HMSTrack? audioTrack;

  PeerTrackNode(
      {required this.uid,
        required this.peer,
        this.audioTrack,
        this.isRaiseHand = false});

  @override
  String toString() {
    return 'PeerTrackNode{uid: $uid, peerId: ${peer.peerId},track: $audioTrack}';
  }

}

