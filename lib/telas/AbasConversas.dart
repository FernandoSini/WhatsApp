import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversas.dart';
import 'package:whatsapp/model/User.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {

  List<Conversas> _listaConversa = List();
  //criando um controlador para o stream, vantagem: podemos adicionar o evento uma vez e caso os dados mudem será recebido os dados
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db  = Firestore.instance;
  String _idUserLogged;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    Conversas conversa = Conversas();
    conversa.nome = "Ana Clara";
    conversa.mensagem =  "Olá, tudo bem?";
    conversa.caminhoFoto = "https://firebasestorage.googleapis.com/v0/b/whatsapp-2f34a.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=bfe91bfc-8287-429f-8fbf-bb04f0f83c4d";

    _listaConversa.add(conversa);

  }

  //adicionando os dados dentro do controlador
  Stream<QuerySnapshot>_adicionarListenerConversas(){
    //adicionando o listener para o ultima conversas
    final stream = db.collection("conversas").document(_idUserLogged).collection("ultima_conversa").snapshots();

    //"escutar" os dados caso eles sejam alterados na estrutura do db, caso algo seja alterado esse stream é chamado
    stream.listen((dados) {
      //passando dados pro controller
      _controller.add(dados);
    });
  }
  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogged = await auth.currentUser();
    _idUserLogged = userLogged.uid;

    _adicionarListenerConversas();

  }

  //fechando a stream
  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {

  //retornar as conversas na aba de conversas
    return StreamBuilder<QuerySnapshot>(
      stream:
      //fonte dos dados, de onde vamos buscar os dados
      //passando os dados para o stream.
      _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot){
        switch (snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.waiting:
          return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ));
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if(snapshot.hasError){
             return Text("Erro ao carregar os dados!");
            } else {
              QuerySnapshot querySnapshot = snapshot.data;
              if (querySnapshot.documents.length ==
                  0) { //significa que não tem nenhuma conversa
                return Center(
                  child: Text(
                    "Você não tem nenhuma mensagem ainda :(",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: _listaConversa.length,
                  itemBuilder: (context, indice){

                    List<DocumentSnapshot> conversas = querySnapshot.documents.toList();
                    DocumentSnapshot item = conversas[indice];

                    String urlImagem  = item["caminhoFoto"];
                    String tipoMensagem = item["tipo"];
                    String mensagem   = item["mensagem"];
                    String nome       = item["nome"];
                    String idDestinatario       = item["idDestinatario"];

                    User usuario = User();
                    usuario.nome = nome;
                    usuario.urlImagem = urlImagem;
                    usuario.idUser = idDestinatario;

                    return ListTile(
                      onTap: (){
                        Navigator.pushNamed(
                            context,
                            "/mensagens",
                            arguments: usuario
                        );
                      },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: urlImagem!=null
                            ? NetworkImage( urlImagem )
                            : null,
                      ),
                      title: Text(
                        nome,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                      subtitle: Text(
                          tipoMensagem == "texto"
                              ? mensagem
                              : "Imagem...",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14
                          )
                      ),
                    );

                  }
              );

            }
        }
      },
    );


  }
}
