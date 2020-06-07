
import 'package:cloud_firestore/cloud_firestore.dart';

class Conversas{

  String _nome;
  String _mensagem;
  String _caminhoFoto;
  String _idRemetente;
  String _idDestinatario;
  String _tipoMensagem; //texto ou imagem

  Conversas();
  
  salvar() async{
    //estrutura da conversa
    /*
    *  +conversas (collection)
    *   +lucas(document)
    *       +ultima_conversa
    *         +fernando(document)
    *
    * */

    //salvando conversas
    //salvando id do remetente e do destinatario no firebase
    Firestore db = Firestore.instance;
    await db.collection("conversas")
        .document( this.idRemetente )
        .collection( "ultima_conversa" )
        .document( this.idDestinatario )
        .setData( this.toMap() );
    //o to map serve para salvar os dados no banco do firebase
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map ={
      "nome": this.nome,
      "mensagem": this.mensagem,
      "idRemetente": this.idRemetente,
      "idDestinatario": this.idDestinatario,
      "caminhoFoto": this.caminhoFoto,
      "tipoMensagem": this.tipoMensagem,

    };
    return map;
  }

  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }

  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }


  String get idDestinatario => _idDestinatario;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }
}