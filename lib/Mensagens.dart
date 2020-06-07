import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'model/Conversas.dart';
import 'model/Mensagem.dart';
import 'model/User.dart';

class Mensagens extends StatefulWidget {
  //passando parametros do tipo usuario para o pushed name do list tile (em Abas contato por argumentos) para quando for clicado no usuario,
  User contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  //criando uma estrutura dentro do firebase
  Firestore db = Firestore.instance;
  String _idUserLogged;
  String _idUserDestino;
  bool _subindoImagem = false;
  TextEditingController _controllerMensagem = TextEditingController();
  ScrollController _scrollController = ScrollController();

  //criando um controlador para o stream, vantagem: podemos adicionar o evento uma vez e caso os dados mudem será recebido os dados
  final _controller = StreamController<QuerySnapshot>.broadcast();

  //enviando a mensagem
  _enviarMensagem() {
    //metodo para enviar mensagem entre os usuarios, pois precisa dos dados do usuário que está logado
    String textoMensagem = _controllerMensagem.text;
    //verificando se a mensagem esta preenchida,
    if (textoMensagem.isNotEmpty) {
      //se o texto mensagem não estiver vazio fazer o envio da mensagem

      Mensagem mensagem = Mensagem();
      //pegando o id do usuario logado
      mensagem.idUser = _idUserLogged;
      //pegando a mensagem
      mensagem.mensagem = textoMensagem;
      //pegando a imagem
      mensagem.urlImagem = "";
      //pegando o tipo da mensagem
      mensagem.tipo = "texto";

      //salvando a mensagem para o remetente
      _salvarMensagem(_idUserLogged, _idUserDestino, mensagem);

      //salvando a mensagem para o destinatário
      _salvarMensagem(_idUserDestino, _idUserLogged, mensagem);

      //Salvando a conversa
      _salvarConversa(mensagem);
    }
  }

  //salvando uma conversa tanto para o remetente quanto para o destinatario
  _salvarConversa(Mensagem msg) async {
    //salvar conversa remetente
    Conversas cRemetente = Conversas();
    cRemetente.idRemetente = _idUserLogged;
    cRemetente.idDestinatario = _idUserDestino;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    //salvar conversa destinatario
    DocumentSnapshot snapshot = await db.collection("usuarios").document( _idUserLogged ).get();
    Conversas cDestinatario = Conversas();
    cDestinatario.idRemetente = _idUserDestino;
    cDestinatario.idDestinatario = _idUserLogged;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = snapshot.data["nome"];
    cDestinatario.caminhoFoto = snapshot.data["urlImagem"];
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  //pra apagar mensagem usa o dismissible

  //salvando a mensagem no firebase
  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap()); //adiciona o item com o identificador firebase

    //limpando o texto
    _controllerMensagem.clear();

    /*
      +mensagens(colecao)
        +pessoa(documento)
          +pessoa receber mensagem(nova colecao com o identificado do firebase)
            +<identificador firebase>
              <Mensagem>
    *
    * */
  }

  _enviarFoto() async {
    PickedFile imagemSelecionada;
    imagemSelecionada =
        await ImagePicker().getImage(source: ImageSource.gallery);

    _subindoImagem = true;
    //caso o usuário tenha mais de uma foto/ou enviar mais de uma foto, podendo ser no mesmo tempo
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child(
            _idUserLogged) //criando essa pasta de segurança, para não fazer upload de muitas imagens com mesmo nome ao mesmo tempo, as imagens serão salvas dentro dessa pasta do user, então se o user apagar essa imagem, o destinatario não terá acesso a imagem
        .child(
            nomeImagem + ".jpg"); //no caso a imagem em precisa receber o userid

    //upload da imagem
    StorageUploadTask task = arquivo.putFile(File(imagemSelecionada.path));

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
    Mensagem mensagem = Mensagem();
    //pegando o id do usuario logado
    mensagem.idUser = _idUserLogged;
    //pegando a mensagem
    mensagem.mensagem = "";
    //pegando a imagem
    mensagem.urlImagem = url;
    //pegando o tipo da mensagem
    mensagem.tipo = "imagem";

    //Salvar mensagem para remetente
    _salvarMensagem(_idUserLogged, _idUserDestino, mensagem);

    //Salvar mensagem para o destinatário
    _salvarMensagem(_idUserDestino, _idUserLogged, mensagem);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogged = await auth.currentUser();
    _idUserLogged = userLogged.uid;

    _idUserDestino = widget.contato.idUser;
    _adicionarListenerMensagens();

  }
  Stream<QuerySnapshot> _adicionarListenerMensagens(){

    final stream = db.collection("mensagens")
        .document(_idUserLogged)
        .collection(_idUserDestino)
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } );
    });

  }



  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            //ocupando todo o espaçamento
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Escreva a sua mensagem...",
                    filled: true,
                    // quando for preenchido
                    fillColor: Colors.white,
                    // preenche o a cor de fundo da caixa de texto
                    border: OutlineInputBorder(
                        //borda externa
                        borderRadius: BorderRadius.circular(32)),
                    //colocando a imagem dentro do txt field
                    prefixIcon:
                        //se estiver subindo imagem vai mostrar o progress indicator, caso contrario exibe o icon button
                        _subindoImagem
                            ? CircularProgressIndicator()
                            : IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: _enviarFoto,
                              )),
              ),
            ),
          ),
          Platform.isIOS
              ? CupertinoButton(
                  child: Text("Enviar"),
                  onPressed: _enviarMensagem,
                )
              : FloatingActionButton(
                  backgroundColor: Color(0xff075e54),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  mini: true,
                  onPressed: _enviarMensagem,
                )
        ],
      ),
    );

    var stream = StreamBuilder(
      //strem builder serve para recuperar os dados quando eles forem atualizados
      stream: _controller.stream,
      //a cada mudança seremos notificados
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
                child: Column(
              children: [
                Text("Carregando mensagens"),
                CircularProgressIndicator()
              ],
            ));
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            //recuperando os dados
            QuerySnapshot querySnapshot = snapshot.data;
            if (snapshot.hasError) {
              //na tela de mensagem mandará um erro caso tenha erro
              return Expanded(
                child: Text("Erro ao carregar os dados"),
              );
            } else {
              return Expanded(
                //ocupandoo espaço disponivel
                child: ListView.builder(
                  controller: _scrollController,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, index) {
                      //recuperando as mensagens
                      List<DocumentSnapshot> mensagens =
                          querySnapshot.documents.toList();
                      //recuperando um item especifico da mensagem
                      DocumentSnapshot item = mensagens[index];

                      //largura ficando com 80% do espaço total
                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //definindo cores e alinhamentos para as mensagens
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xffd2ffa5);

                      //testando se o id do user logado é diferente do id do usario que está dentro da mensagem
                      if (_idUserLogged != item["idUser"]) {
                        //se for  vai alterar a cor
                        alinhamento = Alignment.centerLeft;
                        cor = Colors.white;
                      }

                      //interface de mensagens
                      return Align(
                        //alinhamentos
                        alignment: alinhamento,
                        //espaçamento entre os itens
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: cor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: //verificando se o item for do tipo texto edntro do child vai gcarregar o text se não vai carregar a imagem
                                item["tipo"] == "texto"
                                    ? Text(
                                        item["mensagem"],
                                        style: TextStyle(fontSize: 18),
                                      )
                                    : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    }),
              );
            }
            break;
        }
      },
    );

//    var listView = Expanded(
//      //ocupandoo espaço disponivel
//      child: ListView.builder(
//          itemCount: listaMensagens.length,
//          itemBuilder: (context, index) {
//            //largura ficando com 80% do espaço total
//            double larguraContainer = MediaQuery
//                .of(context)
//                .size
//                .width * 0.8;
//
//            //definindo cores e alinhamentos para as mensagens
//            Alignment alinhamento = Alignment.centerRight;
//            Color cor = Color(0xffd2ffa5);
//
//            //testando se é par ou impar
//            if (index % 2 == 0) {
//              //se for par vai alterar a cor
//              cor = Colors.white;
//              alinhamento = Alignment.centerLeft;
//            }
//
//            //interface de mensagens
//            return Align(
//              //alinhamentos
//              alignment: alinhamento,
//              //espaçamento entre os itens
//              child: Padding(
//                padding: EdgeInsets.all(6),
//                child: Container(
//                  width: larguraContainer,
//                  padding: EdgeInsets.all(16),
//                  decoration: BoxDecoration(
//                      color: cor,
//                      borderRadius: BorderRadius.all(Radius.circular(8))),
//                  child: Text(
//                    listaMensagens[index],
//                    style: TextStyle(fontSize: 18),
//                  ),
//                ),
//              ),
//            );
//          }),
//    );

    return Scaffold(
      appBar: AppBar(
        //avatar com o nome
        title: Row(
          children: [
            CircleAvatar(
                maxRadius: 20, //tamanho do radius
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.urlImagem != null
                    ? NetworkImage(widget.contato.urlImagem)
                    : null),
            Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(widget.contato.nome)),
          ],
        ),
      ),
      body: Container(
        //ocupando todo o espaco disponivel
        width: MediaQuery.of(context).size.width,
        //safe area otimiza a tela pro ios e pro android utilizando media query, ou seja, garante uma exibição segura(cria uma area segura para exibição)
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [stream, caixaMensagem],
            ),
          ),
        ),
      ),
    );
  }
}
