import 'package:flutter/material.dart';
import 'package:hms_callkit/home_page.dart';
import 'package:hms_callkit/meeting_page.dart';
import 'package:hms_callkit/preview_page.dart';

class AppRoute {
  static const homePage = '/home_page';

  static const callingPage = '/meeting_page';
  static const previewPage = '/preview_page';
  

  static Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
            builder: (_) => HomePage(), settings: settings);
      case callingPage:
        return MaterialPageRoute(
            builder: (_) => MeetingPage(authToken:settings.arguments as String?, userName: 'Test User',), settings: settings);
      case previewPage:
        return MaterialPageRoute(
            builder: (_) => PreviewPage(authToken:settings.arguments as String?, userName: 'Test User',), settings: settings);
      default:
        return null;
    }
  }
}
