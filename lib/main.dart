import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/RouteGenerator.dart';

import 'Login.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        primaryColor: Color(0xff075e54),
        accentColor: Color(0xff25d366)
      ),
    //personalizando/centralizando as rotas
    initialRoute: "/",
    //rotas centralizadas
    onGenerateRoute: RouteGenerator.generateRoute,
    home: Login(),
  ));
}
