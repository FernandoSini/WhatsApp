import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';

import 'Home.dart';
import 'model/User.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  _validarCampos() {
    //recuperando os dados dos campos
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    //testando se o nome não está vazio
    if (email.isNotEmpty && email.contains("@")) {
        if(senha.isNotEmpty){
          setState(() {
            _mensagemErro = "";
          });

          User usuario = User();
          usuario.email = email;
          usuario.senha = senha;
          _logarUsuario(usuario);
        }
        else{
          setState(() {
            _mensagemErro = "Preencha a senha";
          });
        }
    } else {
      setState(() {
        _mensagemErro = "Preencha o Email corretamente";
      });
    }
  }

  _logarUsuario(User usuario){
    //autenticando user
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((firebaseUser){
      Navigator.pushReplacementNamed(context, "/home");
    }).catchError((error){
      setState(() {
        _mensagemErro = "Error when trying do authenticate your user, please verify your e-mail and password";
      });
    });
  }

  //metodo que controla se o usuario esteja logado no app,e não tenha que fazer o login
  // denovo, e entre automaticamente

  Future _verificarUsuarioLogado() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();
    //pegando o usuario atual
    FirebaseUser userLogged = await auth.currentUser();
    //verificando se o usuario está logado e redirecionando para a tela de login
    if(userLogged != null){
//      Navigator.pushReplacement(context, MaterialPageRoute(
//          builder: (context) => Home() ));
        //outra forma de fazer o navigator push, com as rotas centralizadas no route generator
        Navigator.pushReplacementNamed(context, "/home");

    }
  }
  @override
  void initState() {
    //chamando o método que verifica se ele esta logado, para redirecionar para a tela inicial
    _verificarUsuarioLogado();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075e54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  //espaçamento entre o texto e o logo
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  //espaçamento entre as caixas de texto
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        // quando for preenchido
                        fillColor: Colors.white,
                        // preenche o a cor de fundo da caixa de texto
                        border: OutlineInputBorder(
                          //borda externa
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      // quando for preenchido
                      fillColor: Colors.white,
                      // preenche o a cor de fundo da caixa de texto
                      border: OutlineInputBorder(
                        //borda externa
                          borderRadius: BorderRadius.circular(32))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      _validarCampos();
                    },
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? Cadastre-se",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      //mudando de tela
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Cadastro()));
                    },
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        _mensagemErro,
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
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
