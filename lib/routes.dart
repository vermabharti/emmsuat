import 'package:emms/registration.dart';
import 'package:flutter/material.dart';
import 'complainthome.dart';
import 'loggedIn.dart';
import 'login.dart';

// Navigation/Routing 

final routes = {
  '/': (BuildContext context) => new IsLoggedIn(),
  '/login': (BuildContext context) => new LoginPage(),
  '/signup': (BuildContext context) => new Registration(),
  '/homecomplaint': (BuildContext context) => new ComplaintHomePage(
        arguments: null,
        userN: null,
      ),
};
