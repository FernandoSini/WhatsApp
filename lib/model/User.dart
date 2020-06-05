
class User{

  String _nome;
  String _senha;
  String _urlImagem;
  String _email;


  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  User();

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map ={
      "nome": this.nome,
      "email": this.email
    };
    return map;
  }

  String get email => _email;

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  set email(String value) {
    _email = value;
  }


  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }
}