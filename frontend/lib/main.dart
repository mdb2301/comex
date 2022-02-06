import 'package:comex/API.dart';
import 'package:comex/Authentication.dart';
import 'package:comex/Storage.dart';
import 'package:comex/placepolygon.dart';
import 'package:comex/register.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'CustomUser.dart';
import 'home.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Mulish',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen()
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Route login(){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Login(),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin:Offset(-1,0),end:Offset.zero)),
          child: child,
        );
      },
    );
  }

  Route home(CustomUser user,dynamic auth){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Home(user: user,auth:auth),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin:Offset(-1,0),end:Offset.zero)),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkStorage();
  }

  checkStorage() async {
    StorageResponse res = await Storage().read();
    if(res.isLoggedIn != null){
      if(res.isLoggedIn){
        var r = await API().getUser(res.firebaseId);
        print(res.firebaseId);
        if(r.code==0){
          Navigator.of(context).push(home(r.user,res.type));
          return;
        } 
      }        
    }
    Navigator.of(context).push(login());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        child:Center(
          child: Text("ComEx",style:TextStyle(fontSize:25,fontWeight:FontWeight.bold))
        )
      )
    );
  }
}

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  bool emailError,passwordError,hide,loading;CustomUser user;
  TextEditingController emailcontroller,passwordcontroller;
  @override
  void initState(){
    emailcontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    emailError = false;
    passwordError = false;
    hide = true;
    loading = false;
    super.initState();
  }

  Route register(){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Register(),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin: Offset(1.0,0.0),end: Offset.zero)),
          child: child,
        );
      },
    );
  }

  Route home(CustomUser user,dynamic auth){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Home(user:user,auth: auth,),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin:Offset(-1,0),end:Offset.zero)),
          child: child,
        );
      },
    );
  }

  signin() async {
    setState(() {
      loading = true;
    });
    final email = emailcontroller.value.text.trim();
    final password = passwordcontroller.value.text.trim();
    final auth = Email();
    AuthResponse res = await auth.signInWithEmailAndPassword(email, password);
    switch(res.code){
      case 0:
        final apiResponse = await API().getUser(res.user.firebaseId);
        if(apiResponse.code==0){
          final storage = Storage();
          final r = await storage.write(apiResponse.user.firebaseId,auth.type);
          if(r.code==1){
            Navigator.of(context).push(home(res.user,auth.type));
          }
        }
        break;
      case 1:
        setState(() {
          emailError = true;
          loading = false;
        });
        break;
      case 2:
        setState(() {
          passwordError = true;
          loading = false;
        });
    }
  }

  Route createfence(CustomUser user, dynamic auth, LatLng location){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => PlacePolygonBody(user:user,auth:auth,location:location,),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin:Offset(-1,0),end:Offset.zero)),
          child: child,
        );
      },
    );
  }

  uploadUser(CustomUser user,dynamic auth) async {
    APIResponse x = await API().checkFence();
    print("\n\n${x.code}\n\n");
    switch(x.code){
      case 0:
        user.fenceId = x.fenceId;
        APIResponse r = await API().addUser(user);
        if(r.code==0){
          Storage storage = Storage();
          var x = await storage.write(r.user.firebaseId, auth.type);
          if(x.code==0){
            Navigator.of(context).push(home(r.user,auth.type));
          }else{
            print(x.message);
          }
        }else{
          print("Error registering"+r.message);
          auth.deleteUser();
        }
        break;
      case 61:
        final location = await getLocation();
        Navigator.of(context).push(createfence(user,auth,location));
        break;
      default:
        setState((){
          loading = false;
        });
    }
  }

  facebook() async {
    final facebookauth = Facebook();
    final res = await facebookauth.continueWithFacebook();
    if(res.code==0){
      final apiResponse = await API().getUser(res.user.firebaseId);
      if(apiResponse.code==0){
        Storage storage = Storage();
        var x = await storage.write(apiResponse.user.firebaseId, facebookauth.type);
        if(x.code==0){
          Navigator.of(context).push(home(apiResponse.user,facebookauth.type));
        }else{
          print(x.message);
        }
      }else{
        uploadUser(res.user,facebookauth);
      }
    }else{
      //error dialog
    }
  }

  google() async {
    final googleSignIn = Google();
    googleSignIn.initialize().then((v) async {
      final res = await googleSignIn.continueWithGoogle();
      if(res.code==0){
        final apiResponse = await API().getUser(res.user.firebaseId);
        if(apiResponse.code==0){
          Storage storage = Storage();
          var x = await storage.write(apiResponse.user.firebaseId, googleSignIn.type);
          if(x.code==0){
            Navigator.of(context).push(home(apiResponse.user,googleSignIn.type));
          }else{
            print(x.message);
          }
        }else{
          print("Else:${res.user.name}");
          uploadUser(res.user,googleSignIn);
        }
      }else{
        print(res.code);
      }
    });
  }

  getLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if(!serviceEnabled){
      serviceEnabled = await location.requestService();
      if(!serviceEnabled){
        return null;
      }
    }
    PermissionStatus permission = await location.hasPermission();
    if(permission==PermissionStatus.denied){
      permission = await location.requestPermission();
      if(permission != PermissionStatus.granted){
        return null;
      }
    }
    LocationData data = await location.getLocation();
    return LatLng(data.latitude,data.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right:20,top:20),
                        child: GestureDetector(
                          onTap: null,
                          child: Text("Trouble logging in?",style:TextStyle(fontSize: 15,color:Color.fromRGBO(8, 199, 68, 1)))
                        ),
                      )
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child:Padding(
                        padding: const EdgeInsets.only(top:30,left:50),
                        child: Text("Login",style:TextStyle(fontSize: 50,color:Color.fromRGBO(69, 69, 69, 1))),
                      )
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child:Padding(
                        padding: const EdgeInsets.only(top:50,left:60,right:40),
                        child: Row(
                          children: <Widget>[
                            Text("Email",style:TextStyle(fontSize: 18,color:Color.fromRGBO(82,93,92,1))),
                            Expanded(child: Container(),),
                            Visibility(
                              visible: emailError,
                              child: Text("Invalid Email",style:TextStyle(color:Colors.red[400])),
                            )
                          ],
                        ),
                      )
                    ),
                    Container(
                      alignment: Alignment.center,
                      child:Padding(
                        padding: const EdgeInsets.only(top:10,left:40,right:40),
                        child: TextField(
                          onEditingComplete: ()=>FocusScope.of(context).nextFocus(),
                          controller: emailcontroller,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical:13),
                            filled: true,
                            fillColor: emailError ? Colors.red[100] : Color.fromRGBO(246, 246, 246, 1),
                            prefixIcon: Icon(Icons.alternate_email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                            ), 
                          ),
                        ),
                      )
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child:Padding(
                        padding: const EdgeInsets.only(top:30,left:60,right:40),
                        child: Row(
                          children: <Widget>[
                            Text("Password",style:TextStyle(fontSize: 18,color:Color.fromRGBO(82,93,92,1))),
                            Expanded(child: Container(),),
                            Visibility(
                              visible: passwordError,
                              child: Text("Incorrect Password",style:TextStyle(color:Colors.red[400])),
                            )
                          ],
                        ),
                      )
                    ),
                    Container(
                      alignment: Alignment.center,
                      child:Padding(
                        padding: const EdgeInsets.only(top:10,left:40,right:40),
                        child: TextField(
                          onEditingComplete: ()=>signin(),
                          controller: passwordcontroller,
                          obscureText: true,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical:13),
                            filled: true,
                            fillColor: passwordError ? Colors.red[100] : Color.fromRGBO(246, 246, 246, 1),
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon:GestureDetector(
                              onTap: ()=>{
                                setState((){
                                  hide = !hide;
                                })
                              },
                              child: Icon(hide ? Icons.visibility_off : Icons.visibility,color:Colors.black),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                            ), 
                          ),
                        ),
                      )
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right:60,top:20),
                        child: GestureDetector(
                          onTap: null,
                          child: Text("Forgot password?",style:TextStyle(fontSize: 16,color:Color.fromRGBO(8, 199, 68, 1)))
                        ),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:20),
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [Color.fromRGBO(3, 163, 99, 1),Color.fromRGBO(8, 199, 68, 1)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight
                          )
                        ),
                        alignment: Alignment.center,
                        child: MaterialButton(
                          onPressed: signin,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Log In",style:TextStyle(color:Colors.white,fontSize: 18)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left:10),
                                child: Icon(Icons.exit_to_app,color:Colors.white),
                              )
                            ],
                          ),
                        )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't have an account? ",style:TextStyle(fontSize:15,fontFamily: 'Mulish-Reg')),
                          GestureDetector(
                            onTap: ()=>Navigator.of(context).push(register()),
                            child: Text("Sign up",style:TextStyle(fontSize:15))
                          )
                        ],
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:30,left:30,right:30),
                      child: Image.asset('assets/or.png')
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:30,bottom:20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:20),
                            child: GestureDetector(
                              onTap: ()=>facebook(),
                              child: Image.asset('assets/fb.png',scale: 2.5,)
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:20),
                            child: GestureDetector(
                              onTap: ()=>google(),
                              child: Image.asset('assets/google.png',scale: 2.5,)
                            ),
                          )
                        ],
                      )
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset('assets/bottom.png')
                    )
                  ],
                ),
                loading ? 
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(3, 163, 99, 1))),
                  ),
                ):
                Positioned(
                  bottom: 0,
                  height: 0,
                  width: 0,
                  child: Container()
                )
              ],
            ),
          )
        )
      ),
    );
  }
}




