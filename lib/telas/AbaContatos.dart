import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversas.dart';
import 'package:whatsapp/model/User.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {

  String _idUserLogged;
  String _emailUserLogged;

  //retornando lista de contatos
  Future<List<User>> _recuperarContatos() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot =
        await db.collection("usuarios").getDocuments();

    List<User> listaUsers = List();

    for (DocumentSnapshot item in querySnapshot.documents) {
      //convertendo o retorno de document snapshot para lista de users
      var dados = item.data; //retorna um map

      //se for a mesma pessoa que está logada, não pode exibir-lá ou adiciona-la
      if(dados["email"] == _emailUserLogged) continue; //o continue faz com que o for pule para o proximo item

      User user = User();
      user.email = dados["email"];
      user.nome = dados["nome"];
      user.urlImagem = dados["urlImagem"];

      listaUsers.add(user);
    }
    return listaUsers;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogged = await auth.currentUser();
    _idUserLogged = userLogged.uid;
    _emailUserLogged = userLogged.email;


  }

  //chamado antes do build
  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _recuperarContatos(),

      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando contatos"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
           return ListView.builder(
                // definindo uma lista
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {

                  //lista users
                  List<User> listaItens = snapshot.data;
                  User user = listaItens[index];

                  return ListTile(
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30, //tamanho do radius
                      backgroundColor: Colors.grey,
                      backgroundImage:
                      user.urlImagem != null
                          ? NetworkImage(user.urlImagem)
                          : null
                    ),
                    title: Text(
                      user.nome,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });

            break;
        }
        return null;
      },
    );
  }
}
