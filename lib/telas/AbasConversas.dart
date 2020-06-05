import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversas.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {

  List<Conversas> listaConversa = [
    Conversas(
        "Ana Clara",
        "Olá, tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-2f34a.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=bfe91bfc-8287-429f-8fbf-bb04f0f83c4d"
    ),
    Conversas(
        "Pedro Silva",
        "o que está fazendo?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-2f34a.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=b7ce15d3-bffa-4052-8cc1-0710eda214f8"
    ),
    Conversas(
        "Luiza",
        "Eae",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-2f34a.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=3dce1c99-a95d-4b49-afe7-4e448fd436fd"
    ),
    Conversas(
        "Ana Clara",
        "Beleza!",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-2f34a.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=4749f681-8d79-4610-9ea4-2a6336d5b687"
    ),
    Conversas(
        "Jamilton Damasceno",
        "Olá, tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-2f34a.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=b24c7bf2-02a3-4ffd-8470-4246f46baf5c"
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // definindo uma lista
        itemCount:listaConversa.length,
        itemBuilder: (context, index) {
          Conversas conversas = listaConversa[index];
          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30, //tamanho do radius
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(conversas.caminhoFoto),
            ),
            title: Text(
              conversas.nome,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            subtitle: Text(
              conversas.mensagem,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14
              ),
            ),
          );
        }
    );
  }
}
