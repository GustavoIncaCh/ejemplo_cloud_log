import 'package:flutter/material.dart';
import 'package:nuevo_log_facebook/appData/controler.dart';
import 'package:nuevo_log_facebook/appData/model/form.dart';

import 'package:nuevo_log_facebook/DriveConection/driveConection.dart';

import 'package:nuevo_log_facebook/facebooklogin/loginWithFacebook.dart';

class AppDataAdd extends StatefulWidget {
  @override
  _AppDataAddState createState() => _AppDataAddState();
}

class _AppDataAddState extends State<AppDataAdd> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // TextField Controllers
  TextEditingController idController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController comentarioController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState.validate()) {
      FeedbackForm feedbackForm = FeedbackForm(
          idController.text,
          nombreController.text,
          areaController.text,
          comentarioController.text);

      FormController formController = FormController((String response) {
        print("Response: $response");
        if (response == FormController.STATUS_SUCCESS) {
          //
          _showSnackbar("Feedback Submitted");
        } else {
          _showSnackbar("Error Occurred!");
        }
      });

      _showSnackbar("Submitting Feedback");

      // Submit 'feedbackForm' and save it in Google Sheet

      formController.submitForm(feedbackForm);
    }
  }

  // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: idController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Ingresa ID";
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: "ID"),
                    ),
                    TextFormField(
                      controller: nombreController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Ingresa nombre";
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: "Nombre"),
                    ),
                    TextFormField(
                      controller: areaController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "ingresa una area";
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: "Area"),
                    ),
                    TextFormField(
                      controller: comentarioController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Ingresa un comentario";
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: "Comentario"),
                    ),
                    RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: _submitForm,
                      child: Text('Subir comentario'),
                    ),
                    RaisedButton(
                      child: Text(
                        "Subir imagen",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (SignInDemo())),
                        );
                      },
                    ),
                    RaisedButton(
                      child: Text(
                        "Salir de Comentarios",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (LoginWithFacebook())),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
