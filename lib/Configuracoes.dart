import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  PickedFile _imagem;
  String _idUserLogged;
  bool _subindoImagem =
      false; //definindo o padrão como false pq ainda não foi, uploadado, mas caso seja, será mudada para true
  String _urlImagemRecuperada;

  Future _recuperarImagem(String origemImagem) async {
    PickedFile imagemSelecionada;
    switch (origemImagem) {
      case "camera":
        imagemSelecionada =
            await ImagePicker().getImage(source: ImageSource.camera);
        break;
      case "galeria":
        imagemSelecionada =
            await ImagePicker().getImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = imagemSelecionada;
      if (_imagem != null) {
        _subindoImagem = true;
        _uploadImage();
      }
    });
  }

  Future _uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child("perfil").child(
        _idUserLogged + ".jpg"); //no caso a imagem em precisa receber o userid

    //upload da imagem
    StorageUploadTask task = arquivo.putFile(File(_imagem.path));

    //controlando o progresso do upload
    task.events.listen((StorageTaskEvent storageEvent) {
      //testando o status do upload se ele estiver em progresso
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true; // pois ainda está em progresso
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        //quando deu certo o upload
        setState(() {
          _subindoImagem = false; //porque foi concluido o upload
        });
      }
    });
    //recuperando o url da imagem
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  //recuperando a url da imagem
  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    //pegando a url
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore(url);

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarUrlImagemFirestore(String url) {
    Firestore db = Firestore.instance;

    //map com os dados que eu quero atualizar
    Map<String, dynamic> dadosAtualizar = {
      "urlImagem": url
    };

    db.collection("usuarios")
        .document(_idUserLogged)
        .updateData(dadosAtualizar);
  }

  _atualizarNomeFirestore() {
    String nome = _controllerNome.text;
    Firestore db = Firestore.instance;

    //map com os dados que eu quero atualizar
    Map<String, dynamic> dadosNome = {
      "nome": nome
    };

    db.collection("usuarios")
        .document(_idUserLogged)
        .updateData(dadosNome);
  }

    _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogged = await auth.currentUser();
    _idUserLogged = userLogged.uid;

    //recuperando a urlImagem e o nome,
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").document(_idUserLogged).get();


    Map<String, dynamic> dados = snapshot.data;
    _controllerNome.text = dados["nome"];
    //verificando  se existe a url imagem
    if( dados["urlImagem"] != null ){
      setState(() {
        _urlImagemRecuperada = dados["urlImagem"];
      });

    }
  }

  @override
  void initState() {
    super.initState();
    //trocando a imagem de perfil
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurações')),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //validando
                Container(
                  padding: EdgeInsets.all(16),
                  child: _subindoImagem ? CircularProgressIndicator() : Container(),
                ),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    //testando se a imagem for diferente de null deve exibir a imagem recuperada caso contrario será nulo
                    backgroundImage: _urlImagemRecuperada != null
                        ? NetworkImage(_urlImagemRecuperada)
                        : null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      child: Text("Câmera"),
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria"),
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                    ),
                  ],
                ),
                Padding(
                  //espaçamento entre as caixas de texto
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    /*onChanged: (texto){
                      _atualizarNomeFirestore(texto);
                    },*/ //salvar o texto sem o botão salvar
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        // quando for preenchido
                        fillColor: Colors.white,
                        // preenche o a cor de fundo da caixa de texto
                        border: OutlineInputBorder(
                            //borda externa
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
               Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      _atualizarNomeFirestore();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
