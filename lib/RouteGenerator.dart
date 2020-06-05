import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Login.dart';

import 'Configuracoes.dart';
import 'Home.dart';

class RouteGenerator{
   //static const String ROTA_HOME = "/home"; //é o recomendado em vez de ficar /home
  //static facilita acesso ao conteudo da classe
  static Route<dynamic> generateRoute(RouteSettings settings){
    //tratando/configurando as rotas
  //busca o name do NavigatorPushNamed
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (context) => Login()
        );
        case "/login":
        return MaterialPageRoute(
          builder: (context) => Login()
        );
         case "/cadastro":
        return MaterialPageRoute(
          builder: (context) => Cadastro()
        );
        case "/home":
         return MaterialPageRoute(
            builder: (context) => Home()
        );
         case "/configuracoes":
         return MaterialPageRoute(
            builder: (context) => Configuracoes()
        );
      default:
        _erroRota();
    }
  }
  static Route<dynamic> _erroRota(){
    MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada"),
        ),
      );
    });
  }
}
