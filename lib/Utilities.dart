import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:hms_callkit/app_router.dart';
import 'package:hms_callkit/hmssdk_interactor.dart';
import 'package:hms_callkit/navigation_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

Uuid? _uuid;
String? _currentUuid;
String textEvents = "";
late final FirebaseMessaging _firebaseMessaging;
String fcmToken = "";
Color hmsdefaultColor = const Color.fromRGBO(36, 113, 237, 1);
bool isHandled = false;
//Handles when app is in background or terminated
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  var response = jsonDecode(message.data["params"]);
  CallKitParams data = CallKitParams.fromJson(response);
  if (data.extra?.containsKey("authToken") ?? false) {
    placeCall(data.extra!["authToken"]);
  } else {
    log("No Valid authToken found");
  }
}

void initFirebase() async {
  _uuid = const Uuid();
  await Firebase.initializeApp();
  _firebaseMessaging = FirebaseMessaging.instance;
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus != AuthorizationStatus.authorized) {
    return;
  }
  fcmToken = await _firebaseMessaging.getToken() ?? "";
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    log("Value is ${message.data["params"]}");
    var response = jsonDecode(message.data["params"]);
    CallKitParams data = CallKitParams.fromJson(response);
    if (data.extra?.containsKey("authToken") ?? false) {
      placeCall(data.extra!["authToken"]);
    } else {
      log("No Valid authToken found");
    }
  });
  _firebaseMessaging.getToken().then((token) {
    log('Device Token FCM: $token');
  });
  initCurrentCall();
}

_getCurrentCall() async {
  //check current call from pushkit if possible
  var calls = await FlutterCallkitIncoming.activeCalls();
  if (calls is List) {
    if (calls.isNotEmpty) {
      log('DATA: $calls');
      _currentUuid = calls[0]['id'];
      return calls[0];
    } else {
      _currentUuid = "";
      return null;
    }
  }
}

Future<void> placeCall(String authToken) async {
  await FlutterCallkitIncoming.showCallkitIncoming(getCallInfo(authToken));
}

void checkAndNavigationCallingPage() async {
  var currentCall = await _getCurrentCall();
    print("HMSSDK Here");
  // if (currentCall != null) {
  //     NavigationService.instance.pushNamedIfNotCurrent(AppRoute.callingPage,
  //         args: currentCall["extra"]["authToken"]);
  //   }
  }

//To make a fake call on same device
Future<void> makeFakeCallInComing() async {
  await Future.delayed(const Duration(seconds: 5), () async {
    _currentUuid = _uuid?.v4();

    final params = CallKitParams(
      id: _currentUuid,
      nameCaller: 'Test User',
      appName: 'Callkit',
      avatar: 'https://i.pravatar.cc/100',
      handle: '0123456789',
      type: 1,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      textMissedCall: 'Missed call',
      textCallback: 'Call back',
      extra: <String, dynamic>{
        'userId': '1a2b3c4d',
        'authToken': "Enter your authToken here",
      },
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        isShowCallback: true,
        isShowMissedCallNotification: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: 'Incoming Call',
        missedCallNotificationChannelName: 'Missed Call',
      ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  });
}

//To start a call but we are directly logging into the meeting
Future<void> startOutGoingCall() async {
  _currentUuid = _uuid?.v4();
  final params = CallKitParams(
    id: _currentUuid,
    nameCaller: 'Hien Nguyen',
    handle: '0123456789',
    type: 1,
    extra: <String, dynamic>{'userId': '1a2b3c4d'},
    ios: IOSParams(handleType: 'number'),
  );
  await FlutterCallkitIncoming.startCall(params);
}

Future<void> activeCalls() async {
  var calls = await FlutterCallkitIncoming.activeCalls();
  log(calls);
}

Future<void> endAllCalls() async {
  await FlutterCallkitIncoming.endAllCalls();
}

initCurrentCall() async {
  //check current call from pushkit if possible
  var calls = await FlutterCallkitIncoming.activeCalls();
  if (calls is List) {
    if (calls.isNotEmpty) {
      log('DATA: $calls');
      _currentUuid = calls[0]['id'];
      return calls[0];
    } else {
      _currentUuid = "";
      return null;
    }
  }
}

Future<void> endCurrentCall() async {
  initCurrentCall();
  await FlutterCallkitIncoming.endCall(_currentUuid!);
}

Future<bool> getPermissions() async {
  if (Platform.isIOS) return true;
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.bluetoothConnect.request();

  while ((await Permission.camera.isDenied)) {
    await Permission.camera.request();
  }
  while ((await Permission.microphone.isDenied)) {
    await Permission.microphone.request();
  }
  while ((await Permission.bluetoothConnect.isDenied)) {
    await Permission.bluetoothConnect.request();
  }
  return true;
}

Future<void> getDevicePushTokenVoIP() async {
  var devicePushTokenVoIP =
      await FlutterCallkitIncoming.getDevicePushTokenVoIP();
  log("Device token is $devicePushTokenVoIP");
  return devicePushTokenVoIP;
}

Future<void> call(
    {required String receiverFCMToken, required String authToken}) async {
  var func = FirebaseFunctions.instance.httpsCallable("notifySubscribers");
  startOutGoingCall();
  await func.call(<String, dynamic>{
    "targetDevices": [receiverFCMToken], //Enter the device fcmToken here
    "messageTitle": "Incoming Call",
    "messageBody": "Someone is calling you...",
    "callkitParams": json.encode(getCallInfo(authToken).toJson())
  });
}

CallKitParams getCallInfo(String authToken) {
  if (_uuid == null) {
    _uuid = const Uuid();
    _currentUuid = _uuid?.v4();
  }
  return CallKitParams(
    id: _uuid?.v4(),
    nameCaller: 'Test User',
    appName: 'HMS Call',
    avatar: 'https://i.pravatar.cc/100',
    handle: '0123456789',
    type: 1,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    textMissedCall: 'Missed call',
    textCallback: 'Call back',
    extra: <String, dynamic>{'authToken': authToken},
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      isShowCallback: true,
      isShowMissedCallNotification: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      backgroundUrl: 'assets/test.png',
      actionColor: '#4CAF50',
    ),
    ios: IOSParams(
      iconName: 'CallKitLogo',
      handleType: '',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
}
