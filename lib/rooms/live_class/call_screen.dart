import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../livemessaging.dart';
import '../../classes.dart';

class CallStart extends StatefulWidget {
  String docId;
  String roomUrl;

  CallStart({Key? key, required this.docId, required this.roomUrl})
      : super(key: key);

  @override
  State<CallStart> createState() => _CallStartState();
}

class _CallStartState extends State<CallStart>
    implements HMSUpdateListener, HMSActionResultListener {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late HMSSDK hmsSDK;
  final List<PeerTrackNode> _listeners = [];
  final List<PeerTrackNode> _speakers = [];
  bool _isMicrophoneMuted = false;
  bool speaker = false;
  bool isScreenShareOn = false;
  HMSPeer? localPeer, remotePeer;
  HMSVideoTrack? localPeerVideoTrack, remotePeerVideoTrack;
  bool fullScreen = false;

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

  Future<void> joinRoom() async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    HMSConfig config = HMSConfig(authToken: widget.roomUrl, userName: name!);
    await hmsSDK.join(config: config);
    hmsSDK.addUpdateListener(listener: this);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermissions();
    initHMSSDK();
  }

  void initHMSSDK() async {
    hmsSDK = HMSSDK();
    await hmsSDK.build();
    joinRoom();
  }

  @override
  void dispose() {
    _speakers.clear();
    _listeners.clear();
    remotePeerVideoTrack = null;
    localPeerVideoTrack = null;

    super.dispose();
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
        List<HMSAudioDevice>? availableAudioDevice}) {
    hmsSDK.switchAudioOutput(
        audioDevice:
        speaker ? HMSAudioDevice.SPEAKER_PHONE : HMSAudioDevice.EARPIECE);
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    // TODO: implement onChangeTrackStateRequest
  }

  @override
  void onException(
      {required HMSActionResultListenerMethod methodType,
        Map<String, dynamic>? arguments,
        required HMSException hmsException}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        log("Not able to leave error occurred");
        break;
      default:
        break;
    }
  }

  @override
  void onHMSError({required HMSException error}) {
    // TODO: implement onHMSError
  }

  @override
  void onJoin({required HMSRoom room}) {
    //Checkout the docs about handling onJoin here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/join#join-a-room
    room.peers?.forEach((peer) {
      if (peer.isLocal) {
        localPeer = peer;
        if (peer.videoTrack != null) {
          localPeerVideoTrack = peer.videoTrack;
        }
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

  @override
  void onMessage({required HMSMessage message}) {
    // TODO: implement onMessage
  }

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers,
        required List<HMSPeer> removedPeers}) {
    // TODO: implement onPeerListUpdate
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (peer.isLocal) {
      localPeer = peer;
    }
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        if (!peer.isLocal) {
          if (mounted) {
            setState(() {
              remotePeer = peer;
            });
          }
        }
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
        if (!peer.isLocal) {
          if (mounted) {
            setState(() {
              remotePeer = null;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              localPeer = null;
            });
          }
        }
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
  void onReconnected() {
    // TODO: implement onReconnected
  }

  @override
  void onReconnecting() {
    // TODO: implement onReconnecting
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    // TODO: implement onRemovedFromRoom
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    // TODO: implement onRoleChangeRequest
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    // TODO: implement onRoomUpdate
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // TODO: implement onSessionStoreAvailable
  }

  @override
  void onSuccess(
      {required HMSActionResultListenerMethod methodType,
        Map<String, dynamic>? arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.endRoom:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const CustomNavBar()));
        break;
      case HMSActionResultListenerMethod.leave:
        hmsSDK.removeUpdateListener(listener: this);
        hmsSDK.destroy();
        break;
      default:
        break;
    }
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
        required HMSTrackUpdate trackUpdate,
        required HMSPeer peer}) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        if (peer.isLocal) {
          if (mounted) {
            setState(() {
              localPeerVideoTrack = null;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              remotePeerVideoTrack = null;
            });
          }
        }
        return;
      }
      if (peer.isLocal) {
        if (mounted) {
          setState(() {
            localPeerVideoTrack = track as HMSVideoTrack;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            remotePeerVideoTrack = track as HMSVideoTrack;
          });
        }
      }
    }
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    // TODO: implement onUpdateSpeakers
  }
  int quizAns = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('live_room')
          .doc(widget.docId)
          .snapshots(),
      builder: (context, snapshot) {
        try {
          if (snapshot.hasData) {
            return Scaffold(
                body: snapshot.data?['screenShare'] == false
                    ? noScreenShareScreen(snapshot)
                    : screenShareScreen(
                    Key(remotePeerVideoTrack?.trackId ?? "" "mainVideo"),
                    remotePeerVideoTrack,
                    context));
          } else if (snapshot.hasError) {
            // Handle the error here
            print("Error: ${snapshot.error}");
            return const Center(
              child: Text(""),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            exitFromClass(context);
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

  void exitFromClass(BuildContext context) {
    hmsSDK.leave(hmsActionResultListener: this);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CustomNavBar()),
    );
  }

  Widget screenShareScreen(
      Key key, HMSVideoTrack? videoTrack, BuildContext context) {
    return Column(
      children: [
        Stack(children: [
          fullScreen == true ? Container(
            height: MediaQuery.of(context).size.height * 0.75,
            width: MediaQuery.of(context).size.width,
            key: key,
            color: Colors.black,
            child: videoTrack != null
                ? HMSVideoView(
              track: videoTrack,
            )
                : const Center(
                child: Text(
                  "Let's learn something new today",
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 18),
                )),
          ) : Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              key: key,
              color: Colors.black,
              child: videoTrack != null
                  ? HMSVideoView(
                track: videoTrack,
              )
                  : const Center(
                  child: Text(
                    "Let's learn something new today",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 18),
                  )),
            ),
          ),
          Positioned(
              bottom: 7,
              right: 5,
              child: fullScreen == false
                  ? InkWell(
                  onTap: ()
                  {
                    setState(() {
                      fullScreen = !fullScreen;
                    });
                  },
                  child: const Icon(Icons.fullscreen, color: Colors.red))
                  : InkWell(
                  onTap: ()
                  {
                    setState(() {
                      fullScreen = !fullScreen;
                    });
                  },
                  child: const Icon(Icons.fullscreen_exit, color: Colors.white))

          ),

        ]),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    speaker = !speaker;
                  });
                  onAudioDeviceChanged();
                },
                child: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(speaker ? Icons.volume_up : Icons.volume_down,
                        color: Colors.white, size: 45))),
            InkWell(
              onTap: () {
                hmsSDK.leave(hmsActionResultListener: this);
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
        Expanded(
          child: MyVideoPlayerr(),
        ),

      ],
    );
  }

  Widget noScreenShareScreen(AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    // return StreamBuilder<DocumentSnapshot>(
    //   stream: FirebaseFirestore.instance
    //       .collection('live_room')
    //       .doc(widget.docId)
    //       .snapshots(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       // Loading state
    //       return const CircularProgressIndicator();
    //     } else if (!snapshot.hasData || !snapshot.data!.exists) {
    //       return Center(child: Text('Live class not found.'));
    //     } else {
    // Document exists, extract data
    var data = snapshot.data!.data() as Map<String, dynamic>;
    bool quizTime = data['quizTime'] ?? false;

    // Check the value of quizTime and display the appropriate screen
    if (quizTime) {
      return quizScreen();
    }
    return noQuizScreen();

    // }
    // },
    // );
  }
  Color containerColor1 = Colors.black;
  Color containerColor2 = Colors.black;
  Color containerColor3 = Colors.black;
  Color containerColor4 = Colors.black;
  bool answerSubmitted = false;
  Widget quizScreen() {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*0.5,
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('live_room').doc(widget.docId).collection('quiz').doc(widget.docId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Quiz not found.'));
                } else {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Q. ${data['question']}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                          Text("A. ${data['A']}", style: TextStyle(
                              color: containerColor1,
                              fontSize: 14
                          )),
                          Text("B. ${data['B']}", style: TextStyle(
                              color: containerColor2,
                              fontSize: 14
                          )),
                          Text("C. ${data['C']}", style: TextStyle(
                              color: containerColor3,
                              fontSize: 14
                          )),
                          Text("D. ${data['D']}", style: TextStyle(
                              color: containerColor4,
                              fontSize: 14
                          )),
                          Container(
                            width: 385.0,
                            height: 115.5,
                            color: Colors.black,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      color: containerColor1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if(answerSubmitted == false) {
                                                quizAns = 1;
                                                containerColor1 = Colors.orange;
                                                containerColor2 = Colors.black;
                                                containerColor3 = Colors.black;
                                                containerColor4 = Colors.black;
                                              }
                                            });
                                          },
                                          child: const Text('A'),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: containerColor2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if(answerSubmitted == false) {
                                                quizAns = 2;
                                                containerColor1 = Colors.black;
                                                containerColor2 = Colors.orange;
                                                containerColor3 = Colors.black;
                                                containerColor4 = Colors.black;
                                              }
                                            });
                                          },
                                          child: const Text('B'),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: containerColor3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if(answerSubmitted == false) {
                                                quizAns = 3;
                                                containerColor1 = Colors.black;
                                                containerColor2 = Colors.black;
                                                containerColor3 = Colors.orange;
                                                containerColor4 = Colors.black;
                                              }
                                            });
                                          },
                                          child: const Text('C'),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: containerColor4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if(answerSubmitted == false) {
                                                quizAns = 4;
                                                containerColor1 = Colors.black;
                                                containerColor2 = Colors.black;
                                                containerColor3 = Colors.black;
                                                containerColor4 = Colors.orange;
                                              }
                                            });
                                          },
                                          child: const Text('D'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  width: 334.86,
                                  height: 29.96,
                                  margin: const EdgeInsets.only(top: 10.03),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(
                                      color: const Color(0xFF24201b),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        answerSubmitted = true;
                                      });
                                      if(quizAns == 1)
                                      {
                                        var count = data['countA'];

                                        FirebaseFirestore.instance.collection('live_room').doc(widget.docId).collection('quiz').doc(widget.docId).update({
                                          'countA': count + 1
                                        });
                                      }
                                      else if(quizAns == 2)
                                      {
                                        var count = data['countB'];
                                        FirebaseFirestore.instance.collection('live_room').doc(widget.docId).collection('quiz').doc(widget.docId).update({
                                          'countB': count + 1
                                        });
                                      }
                                      else if(quizAns == 3)
                                      {
                                        var count = data['countC'];
                                        FirebaseFirestore.instance.collection('live_room').doc(widget.docId).collection('quiz').doc(widget.docId).update({
                                          'countC': count + 1
                                        });
                                      }
                                      else if(quizAns == 4)
                                      {
                                        var count = data['countD'];
                                        FirebaseFirestore.instance.collection('live_room').doc(widget.docId).collection('quiz').doc(widget.docId).update({
                                          'countD': count + 1
                                        });
                                      }
                                      if(quizAns == data['correctOption'])
                                      {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Correct answer'),
                                            duration: Duration(seconds: 3),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        setState(() {
                                          if(quizAns == 1) {
                                            containerColor1 = Colors.green;
                                          } else if(quizAns == 2) {
                                            containerColor2 = Colors.green;
                                          } else if(quizAns == 3) {
                                            containerColor3 = Colors.green;
                                          } else {
                                            containerColor4 = Colors.green;
                                          }
                                        });
                                      }
                                      else
                                      {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Wrong answer'),
                                            duration: Duration(seconds: 3),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        setState(() {
                                          if(quizAns == 1) {
                                            containerColor1 = Colors.red;
                                          } else if(quizAns == 2) {
                                            containerColor2 = Colors.red;
                                          } else if(quizAns == 3) {
                                            containerColor3 = Colors.red;
                                          } else {
                                            containerColor4 = Colors.red;
                                          }
                                        });
                                      }
                                      delayedFunction(3).then((result) {
                                        setState(() {
                                          containerColor1 = Colors.black;
                                          containerColor2 = Colors.black;
                                          containerColor3 = Colors.black;
                                          containerColor4 = Colors.black;
                                          answerSubmitted = false;
                                          quizAns = 0;
                                        });
                                      });

                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF24201b),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        speaker = !speaker;
                      });
                      onAudioDeviceChanged();
                    },
                    child: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(speaker ? Icons.volume_up : Icons.volume_down,
                            color: Colors.white, size: 45))),
                InkWell(
                  onTap: () {
                    hmsSDK.leave(hmsActionResultListener: this);
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
          ],
        ),
      ),
    );
  }

  Future<void> delayedFunction(int seconds) async {
    print('Function execution started');

    // Use Future.delayed to introduce a delay
    await Future.delayed(Duration(seconds: seconds));

    // Your actual function logic goes here
    print('Function executed after $seconds seconds');
  }

  Widget noQuizScreen() {
    // Replace this with your no screen share screen widget
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          const SizedBox(height: 250,),
          const Text('No Screen Share Screen', style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18
          )),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                  onTap: () {
                    setState(() {
                      speaker = !speaker;
                    });
                    onAudioDeviceChanged();
                  },
                  child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(speaker ? Icons.volume_up : Icons.volume_down,
                          color: Colors.white, size: 45))),
              InkWell(
                onTap: () {
                  hmsSDK.leave(hmsActionResultListener: this);
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
        ],
      ),
    );
  }
  Widget peerTile(
      Key key, HMSVideoTrack? videoTrack, HMSPeer? peer, BuildContext context) {
    return Container(
      key: key,
      color: Colors.black,
      child: (videoTrack != null && !(videoTrack.isMute))
          ? HMSVideoView(
        track: videoTrack,
      )
          : Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(4),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.blue,
                blurRadius: 20.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          child: Text(
            peer?.name.substring(0, 1) ?? "D",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600),
          ),
        ),
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

class CustomButton extends StatelessWidget {
  final String buttonName;
  final double topMargin;

  CustomButton({required this.buttonName, required this.topMargin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 61.05,
      height: 42.72,
      margin: EdgeInsets.only(top: topMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Color(0xFF24201b),
      ),
      child: ElevatedButton(
        onPressed: () {
          // Add button functionality here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          buttonName,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}