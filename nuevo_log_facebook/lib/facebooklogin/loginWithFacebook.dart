import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:nuevo_log_facebook/DriveConection/driveConection.dart';
import 'package:nuevo_log_facebook/appData/appDataAdd.dart';
import 'package:nuevo_log_facebook/maps/g_maps.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

class LoginWithFacebook extends StatefulWidget {
  LoginWithFacebook({this.app});
  final FirebaseApp app;
  @override
  _LoginWithFacebookState createState() => _LoginWithFacebookState();
}

class _LoginWithFacebookState extends State<LoginWithFacebook> {
  bool isSignIn = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  FacebookLogin facebookLogin = FacebookLogin();
  Map userData;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('data');
  //CollectionReference pacientes =
  //  FirebaseFirestore.instance.collection('Pacientes');
  CollectionReference pacientes =
      FirebaseFirestore.instance.collection('usuarios');
  CollectionReference control =
      FirebaseFirestore.instance.collection('feedback');

  final referenceDatabase = FirebaseDatabase.instance;
  //StreamBuilder(Stream: FirebaseFirestore.instance.collection(collectionPath) )

  @override
  Widget build(BuildContext context) {
    final ref = referenceDatabase.reference();
    var state_app = 'logeadoFB';
    final state_controler = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Alerta Arequipa"),
      ),
      body: isSignIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.network(
                    userData["picture"]["data"]["url"],
                    height: 50.0,
                    width: 50.0,
                  ),
                  Text(
                    _user.displayName,
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  RaisedButton(
                      child: Text(
                        "Alertas Cercanas",
                        style: TextStyle(color: Colors.blue),
                      ),
                      color: Colors.red[100],
                      onPressed: () {
                        state_app = 'Siguiente pantalla';
                        ref
                            .child('Control')
                            .push()
                            .child(state_app)
                            .set(state_controler.text)
                            .asStream();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              //builder: (context) => (SignInDemo())),
                              builder: (context) => (Gmaps())),
                        );
                      }),
                  RaisedButton(
                      child: Text(
                        "Pantalla de datos",
                        style: TextStyle(color: Colors.blue),
                      ),
                      color: Colors.red[100],
                      onPressed: () {
                        state_app = 'Pantalla de datos';
                        ref
                            .child('Control')
                            .push()
                            .child(state_app)
                            .set(state_controler.text)
                            .asStream();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (AppDataAdd())),
                        );
                      }),
                  /*    
                  FlatButton(
                    onPressed: () {
                      ref
                          .child('Control')
                          .push()
                          .child(state_app)
                          .set(state_controler.text)
                          .asStream();
                    },
                    child: Text('guardar estado'),
                    textColor: Colors.blue,
                  ),
                  */
                  OutlineButton(
                    onPressed: () {
                      gooleSignout();
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
            )
          : Center(
              child: OutlineButton(
                onPressed: () async {
                  await handleLogin();
                },
                child: Text(
                  "Alerta Arequipa con FaceBook",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
    );
  }

  Future<void> handleLogin() async {
    final FacebookLoginResult result =
        await facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = JSON.jsonDecode(graphResponse.body);
        userData = profile;
        collectionReference.add(userData);
        print(userData);
        Map<String, dynamic> dataPacientes = {
          "id": userData["id"],
          "name": userData["name"],
          "email": userData["email"]
        };
        pacientes.add(dataPacientes);
        //pacientes.snapshots();
        try {
          await loginWithfacebook(result);
        } catch (e) {
          print(e);
        }
        //AddUser();
        //collectionReference.add(userData);
        break;
    }
  }

  Future loginWithfacebook(FacebookLoginResult result) async {
    final FacebookAccessToken accessToken = result.accessToken;
    AuthCredential credential =
        FacebookAuthProvider.credential(accessToken.token);
    var a = await _auth.signInWithCredential(credential);
    setState(() {
      isSignIn = true;
      _user = a.user;
    });
  }

  Future<void> gooleSignout() async {
    await _auth.signOut().then((onValue) {
      setState(() {
        facebookLogin.logOut();
        isSignIn = false;
      });
    });
  }
}
