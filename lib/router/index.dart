import 'package:flutter/material.dart';
import 'package:app/pages/door/index.dart';
import 'package:app/pages/people/index.dart';
import 'package:app/pages/scan/index.dart';
import 'package:app/pages/tangevideo/index.dart';
import 'package:app/pages/SplashPage/index.dart';
import 'package:app/pages/home/index.dart';

class RouteNames {
  static const String home = '/';
  static const String door = '/door';
  static const String people = '/people';
  static const String scan = '/scan';
  static const String tangevideo = '/tangevideo';
  static const String splash = '/SplashPage';
}

Map<String, WidgetBuilder> routeTable = {
  RouteNames.home: (context) => const HomePage(),
  RouteNames.door: (context) => const DoorPage(),
  RouteNames.people: (context) => const PeoplePage(),
  RouteNames.scan: (context) => const ScanPage(),
  RouteNames.tangevideo: (context) => const TangeVideoPage(),
  RouteNames.splash: (context) => const SplashPage(),
};
