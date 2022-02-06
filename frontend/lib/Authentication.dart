import 'dart:convert';

import 'package:comex/API.dart';
import 'package:comex/CustomUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
class AuthResponse{
  final CustomUser user;
  final int code;
  final String message;
  AuthResponse({this.code,this.message,this.user});
}

class Email{
  FirebaseAuth auth;
  AuthCredential cred;
  final type = "email";
  Email();

  signOut() async {
    FirebaseApp app = await Firebase.initializeApp();
    auth = FirebaseAuth.instanceFor(app: app);
    auth.signOut();
  }

  Future<AuthResponse> signupWithEmailAndPassword(String email,String password) async {
    try{
      FirebaseApp app = await Firebase.initializeApp();
      auth = FirebaseAuth.instanceFor(app: app);
      UserCredential res = await auth.createUserWithEmailAndPassword(email:email,password:password);
      if(res.user != null){
        return AuthResponse(code:0,user:CustomUser(email:email,firebaseId:res.user.uid,updated:true));
      }else{
        return AuthResponse(code:2,message:"Error");
      }
    }on FirebaseAuthException catch(e){
      if(e.code == 'email-already-in-use'){
        return AuthResponse(code:1,message:"Already exists");
      }
      return AuthResponse(code:2,message:e.message);
    }
  }

  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    try{
      FirebaseApp app = await Firebase.initializeApp();
      auth = FirebaseAuth.instanceFor(app: app);
      final value = await auth.signInWithEmailAndPassword(email: email, password: password);
      cred = value.credential;
      APIResponse res = await API().getUser(value.user.uid);
      if(res.code==0){
        print("uid:${res.user.name}");
        return AuthResponse(code:0,message:"User found",user:res.user);
      }
    }on FirebaseAuthException catch (e){
      if(e.code == 'user-not-found'){
        return AuthResponse(code:1,message:"User not found");
      }
      if(e.code == 'wrong-password'){
        return AuthResponse(code:2,message:"Wrong Password");
      }
      return AuthResponse(code:3,message:e.message);
    }
    return AuthResponse(code:4,message:"Unknown error");
  }

  deleteUser() async {
    try{
      FirebaseApp app = await Firebase.initializeApp();
      auth = FirebaseAuth.instanceFor(app: app);
      auth.currentUser.delete();
    }catch(e){
      print(e);
      auth.currentUser.reauthenticateWithCredential(cred);
      auth.currentUser.delete();
    }
  }
}

class Facebook{
  FacebookLogin facebookLogin;
  final type = "facebook";
  Facebook(){
    facebookLogin = FacebookLogin();
  }

  Future<AuthResponse> continueWithFacebook() async {
    var res = await facebookLogin.logIn(['email']);
    var graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,email&access_token=${res.accessToken.token}');
    var profile = json.decode(graphResponse.body);
    return AuthResponse(code:0,user:CustomUser(name: profile["name"],email: profile["email"],firebaseId: profile["id"],updated:false));
  }

  deleteUser() async {
    final token = (await facebookLogin.currentAccessToken).toString();
    final cred = FacebookAuthProvider.credential(token);
    (await FirebaseAuth.instanceFor(app:await Firebase.initializeApp()).signInWithCredential(cred)).user.delete().whenComplete(() => true);
  }
  signOut(){
    facebookLogin.logOut();
  }
}

class Google{
  GoogleSignIn signIn;
  GoogleSignInAccount account;
  FirebaseApp app;
  final type = "google";
  Google(){
    signIn = GoogleSignIn();
  }

  initialize() async {
    app = await Firebase.initializeApp();
    account = await signIn.signIn();
  }

  Future<AuthResponse> continueWithGoogle() async { 
    final authentication = await account.authentication;
    final cred = GoogleAuthProvider.credential(accessToken:authentication.accessToken,idToken:authentication.idToken);
    final User user = (await FirebaseAuth.instanceFor(app:app).signInWithCredential(cred)).user;
    if(user != null){
      print(user.displayName);
      return AuthResponse(code:0,user:CustomUser(name:user.displayName,email:user.email,firebaseId:user.uid,phone:user.phoneNumber,updated:user.phoneNumber!=null));
    }else{
      return AuthResponse(code:1,message:"Failed");
    }
  }

  deleteUser() async {
    final authentication = await account.authentication;
    final cred = GoogleAuthProvider.credential(accessToken:authentication.accessToken,idToken:authentication.idToken);
    (await FirebaseAuth.instanceFor(app:app).signInWithCredential(cred)).user.delete().whenComplete(() => true);
  }

  signOut(){
    signIn.signOut();
  }
}