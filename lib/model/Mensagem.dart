
class Mensagem{

  String _idUser;
  String _mensagem;
  String _urlImagem;
  String _tipo; //define se o tipo da mensagem pode ser texto ou Imagem
  String _data;

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  Mensagem();
//exibir mensagem
  Map<String,dynamic> toMap(){
    Map<String,dynamic> map ={
      "idUser": this.idUser,
      "mensagem": this.mensagem,
      "urlImagem": this.urlImagem,
      "tipo": this.tipo,
      "data": this.data
    };
    return map;
  }


  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get idUser => _idUser;

  set idUser(String value) {
    _idUser = value;
  }
}