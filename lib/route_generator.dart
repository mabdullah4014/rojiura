import 'package:app/ui/home_page.dart';
import 'package:app/ui/landing_page.dart';
import 'package:app/ui/post_detail_page.dart';
import 'package:app/ui/search_post_page.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static const String LANDING = '/Landing';
  static const String HOME = '/Home';
  static const String DETAIL = '/DETAIL';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case LANDING:
        return MaterialPageRoute(builder: (_) => LandingPage());
      case HOME:
        return MaterialPageRoute(builder: (_) => HomePage());
      case DETAIL:
        return MaterialPageRoute(builder: (_) => PostDetailPage(postId: args));
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
