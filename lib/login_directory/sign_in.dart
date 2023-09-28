import 'package:ExplorX/login_directory/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ExplorX/Screens/loading_screen.dart';
import 'package:ExplorX/login_directory/reset_password.dart';
import 'package:ExplorX/login_directory/sign_up.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();


  Future<void> signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text);



      // Navigate to the loading screen
      _navigateToLoadingScreen(userCredential.user!.uid, userCredential.user!.email);
    } catch (error) {
      print("Error $error");
    }
  }




  void _navigateToLoadingScreen(String? userName, String? userEmail) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          userName: userName ?? '',
          userEmail: userEmail ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Background Image
          Image.asset(
            "images/explorX_page-0001.jpg", // Replace with your background image path
            fit: BoxFit.cover,
            //width: double.infinity,
            height: double.infinity,
          ),
          // Your Existing Content
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).size.height * 0.2,
                  20,
                  0,
                ),
                child: Column(
                  children: <Widget>[
                    logoWidget("images/icon.png"),
                    const SizedBox(
                      height: 30,
                    ),
                    reusableTextField(
                      "Enter Email",
                      Icons.person_outline,
                      false,
                      _emailTextController,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    reusableTextField(
                      "Enter Password",
                      Icons.lock_outline,
                      true,
                      _passwordTextController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    forgetPassword(context),
                    firebaseUIButton(context, "Sign In", signIn),
                    signUpOption()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget logoWidget(String imagePath) {
    return Image.asset(
      imagePath,
      width: 140, // Adjust the width as needed
      height: 140, // Adjust the height as needed
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
}
