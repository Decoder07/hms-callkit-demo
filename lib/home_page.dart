//Package imports

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:hms_callkit/utility_functions.dart';
import 'package:hms_callkit/app_navigation/app_router.dart';
import 'package:hms_callkit/hmssdk/join_service.dart';
import 'package:hms_callkit/app_navigation/navigation_service.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController fcmTokenController = TextEditingController();
  TextEditingController roomIdController =
      TextEditingController();

  Future<void> listenerEvent(Function? callback) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print(' HMSSDK HOME: $event');
        switch (event!.event) {
          case Event.ACTION_CALL_INCOMING:
            break;
          case Event.ACTION_CALL_START:
            break;
          case Event.ACTION_CALL_ACCEPT:
            var data = event.body;
            String authToken = data["extra"]["authToken"];
            String userName = data["nameCaller"];
            bool res = await getPermissions();
            if (res) {
            startOutGoingCall();
              NavigationService.instance
                  .pushNamed(AppRoute.callingPage, args: authToken);
            }
            break;
          case Event.ACTION_CALL_DECLINE:
            break;
          case Event.ACTION_CALL_ENDED:
            break;
          case Event.ACTION_CALL_TIMEOUT:
            break;
          case Event.ACTION_CALL_CALLBACK:
            break;
          case Event.ACTION_CALL_TOGGLE_HOLD:
            break;
          case Event.ACTION_CALL_TOGGLE_MUTE:
            break;
          case Event.ACTION_CALL_TOGGLE_DMTF:
            break;
          case Event.ACTION_CALL_TOGGLE_GROUP:
            break;
          case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
            break;
          case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });
    } on Exception {
      print("HMSSDK Exception");
    }
  }

  @override
  void initState() {
    super.initState();
    listenerEvent(onEvent);
  }

  onEvent(event) {
    if (!mounted) return;
    setState(() {
      onEventLogs += "${event.toString()}\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 30.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: RichText(
                          text: const TextSpan(
                              text: "Wanna try out",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                                text: "\nCalling",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 35)),
                            TextSpan(
                              text: "\nShare the code below",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            )
                          ])),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 80,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade900),
                          child: const Center(
                            child: Text(
                              "XXXX-XXXX-XXXX",
                              overflow: TextOverflow.clip,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: deviceFCMToken));
                            Share.share(
                              deviceFCMToken,
                              subject: 'Share device FCM Token',
                            );
                          },
                          child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade900, width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  color: Colors.black),
                              child: const Icon(
                                Icons.copy,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text("Paste the FCM Token here",
                              key: Key('fcm_token_text'),
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: TextField(
                        key: Key('fcm_token_field'),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {},
                        controller: fcmTokenController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                            focusColor: hmsdefaultColor,
                            contentPadding: EdgeInsets.only(left: 16),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Enter the FCM token here',
                            suffixIcon: fcmTokenController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      fcmTokenController.text = "";
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: hmsdefaultColor, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8))),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)))),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text("Paste the room-id here",
                              key: Key('room_id_text'),
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: TextField(
                        key: const Key('room_id_field'),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {},
                        controller: roomIdController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                            focusColor: hmsdefaultColor,
                            contentPadding: const EdgeInsets.only(left: 16),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Enter room-id here',
                            suffixIcon: roomIdController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      roomIdController.text = "";
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: hmsdefaultColor, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8))),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)))),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(hmsdefaultColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ))),
                      onPressed: () async {
                        if (fcmTokenController.text.isEmpty ||
                            roomIdController.text.isEmpty) {
                          return;
                        }
                        await getPermissions();
                        //Enter the tokenEndPoint, role and userId here
                        String? authToken =
                            await getAuthToken(
                            roomId: roomIdController.text,
                            role: "Enter the role here",
                            tokenEndpoint: 
                            "Enter your token endpoint here",
                            userId: "Enter the user Id here");
                        //Checking whether authentication token is null or not
                        if(authToken != null){
                          call(
                              receiverFCMToken: fcmTokenController.text,
                              authToken: authToken);
                          NavigationService.instance.pushNamedIfNotCurrent(
                              AppRoute.previewPage,
                              args: authToken);  
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Call Now',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
