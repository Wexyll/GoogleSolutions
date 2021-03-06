import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import '../components/menu.dart';
import 'components/sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import "package:best_before_app/UpdateDatabase.dart";

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loading = false;
  bool isLoggedIn = false;
  bool showSpinner = false;

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    setState(() {
      loading = true;
    });

    isLoggedIn = await googleSignIn.isSignedIn();

    if (isLoggedIn) {
      userCol = googleSignIn.currentUser.id;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Menu()));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          color: Colors.amber[800],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(image: AssetImage('assets/icon.png'), height: 225),
                SizedBox(height: 50),
                SignInButton(
                  Buttons.Google,
                  text: "Continue with Google",
                  onPressed: () {
                    setState(() {
                      showSpinner = true;
                    });
                    signInWithGoogle().then((result) {
                      if (result != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return Menu();
                            },
                          ),
                        );
                      }
                      setState(() {
                        showSpinner = false;
                      });
                    });
                  },
                ),
                SizedBox(height: 30),
                SignInButton(
                  Buttons.Email,
                  text: "The Test User",
                  onPressed: () {
                    signInTestUser();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return Menu();
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
