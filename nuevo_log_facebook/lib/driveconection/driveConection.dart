// Copyright 2019 The Flutter Authors. All rights reserved.

import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:html';
import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/material.dart';
import 'package:nuevo_log_facebook/facebooklogin/loginWithFacebook.dart';
import 'package:googleapis/drive/v3.dart' as drive;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/drive.readonly',
  ],
);

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

// creamos una clase auxiliar para llamar los url y los headers
// necesarios para llamar a la api de drive
class AuthClient extends http.BaseClient {
  final http.Client _baseClient;
  final Map<String, String> _headers;

  AuthClient(this._baseClient, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _baseClient.send(request);
  }
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount _currentUser;
  //inicializamos una lista vacia para nuestros documentos
  //List<String> _documents = List();
  List<drive.File> _documents = List();
  CollectionReference images_refretences =
      FirebaseFirestore.instance.collection('imagenes');

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        //hacemos un metodo para obtener los documentos
        _getDocuments();
      }
    });
    _googleSignIn.signInSilently();
  }

  void _getDocuments() async {
    var client = http.Client();
    var _header = await _currentUser.authHeaders;
    var _authClient = AuthClient(client, _header);
    //debemos autenticarnos, drive debe otorganos una url que cargue los archivos

    var api = new drive.DriveApi(_authClient);

    // lista de nuestros archivos
    /*
    var fileList = await api.files.list(q: null, pageSize: 20);
    _documents = fileList.files.map((file) => file.name).toList();
    */

    var pageToken = null;
    _documents.clear();
    do {
      // TODO: Change q to search for files, like "name contains 'pdf'"
      var fileList = await api.files.list(
          q: null,
          pageSize: 20,
          pageToken: pageToken,
          supportsAllDrives: false,
          spaces: "drive",
          $fields: "nextPageToken, files(id, name, mimeType, thumbnailLink)");
      pageToken = fileList.nextPageToken;
      _documents.addAll(fileList.files);
      //_documents = fileList.files.map((file) => file.name).toList();
    } while (pageToken != null);

    setState(() {});
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: _currentUser,
            ),
            title: Text(_currentUser.displayName ?? ''),
            subtitle: Text(_currentUser.email ?? ''),
          ),
          const Text("Signed in successfully."),
          Expanded(
            child: ListView.builder(
              itemCount: _documents.length,
              itemBuilder: (BuildContext context, int index) {
                var file = _documents[index];
                if (file.thumbnailLink != null &&
                    file.mimeType.contains("image")) {
                  //print(file.thumbnailLink);
                  return RaisedButton(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              child: Image.network(
                                file.thumbnailLink,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(file.name),
                            )
                          ],
                        ),
                      ),
                      onPressed: () {
                        Map<String, dynamic> dataImages = {
                          "url": file.thumbnailLink,
                        };
                        images_refretences.add(dataImages);
                        print(file.thumbnailLink);
                      });
                } else {
                  Widget leadingIcon;
                  if (file.mimeType.contains("folder")) {
                    leadingIcon = Icon(Icons.folder);
                  }
                  return RaisedButton(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          leading: leadingIcon,
                          title: Text(file.name),
                          subtitle: Text(file.mimeType),
                        ),
                      ),
                      onPressed: () {});
                }
              },
            ),
          ),
          RaisedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
          RaisedButton(
            child: const Text('REFRESH'),
            onPressed: null,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          RaisedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }
  /*
  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: _currentUser,
            ),
            title: Text(_currentUser.displayName ?? ''),
            subtitle: Text(_currentUser.email ?? ''),
          ),
          const Text("Signed in successfully."),
          // documentos generados para la listarlos
          Expanded(
            child: ListView.builder(
              itemCount: _documents.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_documents[index]),
                );
              },
            ),
          ),
          ElevatedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
          ElevatedButton(
            child: const Text('REFRESH'),
            onPressed: null,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}

/*
class DriveConection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Drive Conection"),
        ),
        body: Center(
            child: OutlineButton(
          child: Text(
            "regresemos",
            style: TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginWithFacebook()),
            );
          },
        )));
  }
}
*/
