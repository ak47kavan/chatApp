import 'dart:developer';  // Import for log function
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kri_dhan/helper/dialogs.dart';
import 'package:kri_dhan/screens/home_screen.dart';

import '../../api/apis.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressbar(context);
    _signInWithGoogle().then((user) async{
      Navigator.pop(context);
      if(user !=null){
      log('\nUser: ${user.user?.displayName}');
      log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

      if((await APIs.userExists())){
          Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen())
      );
      }
      else {
        await APIs.createUser().then((Value){
            Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen())
      );
        });
      }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    // Trigger the authentication flow
    try{
      await InternetAddress.lookup("goole.com");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await APIs.auth.signInWithCredential(credential);

    }catch(e){
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, "Something went wrong Check Internet Access!");
      return null;
    }
  }

 // _signOut() async {
   // await FirebaseAuth.instance.signOut();
    //await GoogleSignIn.signOut();
 // }

 @override
  Widget build(BuildContext context) {
   final mq= MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
       automaticallyImplyLeading: false,
        title: Text(
                "AK Chat",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600
                ),
              ),
        
      ),
     body: Stack(children: [
      AnimatedPositioned(
        top: mq.height * .15,
        right:_isAnimate ? mq.width * .25 : -mq.width * .5,
        width: mq.width * .5,
        duration:const Duration(seconds: 1),
        child: Image.asset("images/phone.png")),

        Positioned(
        bottom: mq.height * .15,
        left: mq.width * .05,
        width: mq.width * .9,
        height: mq.height * .06,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 40, 219, 226),
            shape : const StadiumBorder(),
            elevation: 1
          ),
          onPressed: (){
            _handleGoogleBtnClick();
          }, icon: Image.asset("images/search.png",height: mq.height * .03,),label:RichText(text: const TextSpan(
            style: TextStyle(color: Colors.black,fontSize: 16),
            children:[
            TextSpan(text: "Login with "),
            TextSpan(text: "Google",
            style: TextStyle(fontWeight: FontWeight.w500)),
          ] )))),
     ],),
    );
  }
}
