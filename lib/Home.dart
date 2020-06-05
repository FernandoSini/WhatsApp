import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/telas/AbaContatos.dart';
import 'package:whatsapp/telas/AbasConversas.dart';

import 'Login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<String> itensMenu = ["Configurações", "Deslogar"];
  String _emailUser = "";

  Future _recuperarDados() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();
    FirebaseUser userLogged = await auth.currentUser();
    setState(() {
      _emailUser = userLogged.email;
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDados();
    _tabController = TabController(length: 2, vsync: this);
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Configurações":
        Navigator.pushNamed(context, "/configuracoes");
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
    print('Item escolhido: ' + itemEscolhido);
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(
        context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "Conversas"),
            Tab(
              text: "Contatos",
            )
          ],
        ),
        title: Text("WhatsApp"),
        actions: [
          PopupMenuButton<String>(
            //menu superior a esquerda
            onSelected: _escolhaMenuItem,
            //on selected vai tratar as opções escolhidas
            itemBuilder: (context) {
              //constroe as opçoes do menu
              return itensMenu.map((String item) {
                // com o map é necessario percorrer cada um dos itens como objeto e fazer as configuraçõs
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item), //define o valor capturado para testes
                );
              }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [AbaConversas(), AbaContatos()],
      ),
    );
  }
}
