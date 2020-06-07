import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/Mensagens.dart';

import 'Configuracoes.dart';
import 'Home.dart';

class RouteGenerator{
   //static const String ROTA_HOME = "/home"; //é o recomendado em vez de ficar /home
  //static facilita acesso ao conteudo da classe
  static Route<dynamic> generateRoute(RouteSettings settings){
    //aqui fica a configurações relacionados as rotas
    final args = settings.arguments;
    //tratando/configurando as rotas
  //busca o name do NavigatorPushNamed
    //verificando qual rota está sendo chamada
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
         case "/mensagens":
         return MaterialPageRoute(
            builder: (context) => Mensagens(args)
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
