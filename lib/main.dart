import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Login.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance
  .collection("usuarios")
  .document("001")
  .setData({"nome": "Paula tejando"});
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Color(0xff075e54),
      accentColor: Color(0xff25d366)
    ),
    home: Login(),
  ));
}





