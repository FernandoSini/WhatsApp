import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/model/User.dart';

import 'Home.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  //controladores
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  //validar campos
  _validarCampos() {
    //recuperando os dados dos campos
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    //testando se o nome não está vazio
    if (nome.isNotEmpty) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.isNotEmpty && senha.length > 6) {
          setState(() {
            _mensagemErro = "";

            //configurando o user
            User usuario = User();
            usuario.nome = nome;
            usuario.senha = senha;
            usuario.email = email;

            _cadastrarUsuario(usuario);
          });
        } else {
          setState(() {
            _mensagemErro = "Preencha a senha, digitando mais de 6 caracteres";
          });
        }
      } else {
        setState(() {
          _mensagemErro = " Preencha o email com @";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Preencha o nome";
      });
    }
  }

  //cadastrar usuario no firebase
  _cadastrarUsuario(User usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.createUserWithEmailAndPassword(
        email: usuario.email, password: usuario.senha
    ).then((firebaseUser) {

      //salvar dados do usuario no firebase
      Firestore db = Firestore.instance;
      db.collection("usuarios")
      .document(firebaseUser.user.uid)//pegando o uid do user no firebase
      .setData(usuario.toMap());
      //caso deu certo o cadastro, o usuário será redirecionado para a tela principal
//      Navigator.pushReplacement(context, MaterialPageRoute( //pushReplacement substitui a rota
//        builder: (context) => Home()
//      ));
      //forma resumida do navigator comentado
      //Navigator.pushNamed(context, "/home");
      //removendo as rotas anteriores, para evitar conflitos, (_) => false, vai remover todas as rotas até a home
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false );
    }).catchError((error){
      print("erro no app: " + error.toString());
        setState(() {
          _mensagemErro = "Erro ao cadastrar usuário, verifique os campos e tente novamente";
      });
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
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
                    "images/usuario.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  //espaçamento entre as caixas de texto
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
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
                  //espaçamento entre as caixas de texto
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
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
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  //adicionando o padrão de senha
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
                      "Cadastrar",
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
                  child: Text(
                  _mensagemErro,
                  style: TextStyle(color: Colors.red, fontSize: 20),
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
