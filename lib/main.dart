import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'dart:io';

import 'Login.dart';

final ThemeData temaPadrao = ThemeData(
    primaryColor: Color(0xff075e54),
    accentColor: Color(0xff25d366)
);

final ThemeData temaIOS = ThemeData(
    primaryColor: Colors.grey[200],
    accentColor: Color(0xff25d366)
);

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    //personalizando/centralizando as rotas
    initialRoute: "/",
    //rotas centralizadas
    onGenerateRoute: RouteGenerator.generateRoute,
    home: Login(),
  ));
}
