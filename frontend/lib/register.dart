import 'package:comex/API.dart';
import 'package:comex/Authentication.dart';
import 'package:comex/CustomUser.dart';
import 'package:comex/Storage.dart';
import 'package:comex/placepolygon.dart';
import 'package:flutter/material.dart';
import 'package:comex/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'home.dart';
class Register extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  bool dontMatch,alreadyUsed,hide,chide,submit;CustomUser user;
  TextEditingController emailcontroller,usernamecontroller,passwordcontroller,confirmcontroller,phonecontroller;
  @override
  void initState(){
    dontMatch = false;
    alreadyUsed = false;
    hide = true;
    chide = true;
    submit = false;
    emailcontroller = TextEditingController();
    usernamecontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    confirmcontroller = TextEditingController();
    phonecontroller = TextEditingController(text:"+91");
    super.initState();
  }

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

  Route createfence(CustomUser user, dynamic auth, LatLng location){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => PlacePolygonBody(user:user,auth:auth,location: location,),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin:Offset(-1,0),end:Offset.zero)),
          child: child,
        );
      },
    );
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

  signin() async {
    setState(() {
      submit = true;
      FocusScope.of(context).unfocus();
    });
    final auth = Email();
    final email = emailcontroller.value.text.trim();
    final password = passwordcontroller.value.text.trim();
    final confirm = confirmcontroller.value.text.trim();
    if(password==confirm){
      AuthResponse res = await auth.signupWithEmailAndPassword(email, password);
      if(res.code==0){
        uploadUser(res.user,auth);
      }
      if(res.code==2){
        setState(() {
          alreadyUsed = true;
          submit = false;
        });
      }
    }else{
      setState(() {
        dontMatch = true;
        submit = false;
      });
    }
  }

  uploadUser(CustomUser user,dynamic auth) async {
    APIResponse x = await API().checkFence();
    if(auth.type=="email"){
      user.name = usernamecontroller.value.text.trim();
      user.phone = phonecontroller.value.text.trim();
    }
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
          failed();
        }
        break;
      case 61:
        setState((){
          submit = false;
        });
        final loc = await getLocation();
        Navigator.of(context).push(createfence(user,auth.type,loc));
        break;
      default:
        setState((){
          submit = false;
        });
    }
  }

  failed(){
    setState(() {
      submit = false;
      emailcontroller.clear();
      usernamecontroller.clear();
      passwordcontroller.clear();
      confirmcontroller.clear();
    });
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left:20,top:20),
                            child: GestureDetector(
                              onTap: ()=>Navigator.of(context).push(login()),
                              child: Icon(Icons.arrow_back)
                            ),
                          )
                        ),                    
                        Container(                 
                          child: Padding(
                          padding: const EdgeInsets.only(right:20,top:20),
                          child: GestureDetector(
                            onTap: null,
                            child: Text("Trouble signing up?",style:TextStyle(fontSize: 15,color:Color.fromRGBO(8, 199, 68, 1),))
                          ),
                        )
                      ),
                      ],
                    ),
                  Container(
                    alignment: Alignment.topLeft,
                    child:Padding(
                      padding: const EdgeInsets.only(top:30,left:50),
                      child: Text("Register",style:TextStyle(fontSize: 50,color:Color.fromRGBO(69, 69, 69, 1))),
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
                            visible: alreadyUsed,
                            child: Text("Email already registered",style:TextStyle(color:Colors.red[400])),
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
                          contentPadding: EdgeInsets.symmetric(vertical:10),
                          filled: true,
                          fillColor: alreadyUsed ? Colors.red[100] : Color.fromRGBO(246, 246, 246, 1),
                          prefixIcon: Icon(Icons.alternate_email,color: Color.fromRGBO(82,93,92,1)),
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
                      padding: const EdgeInsets.only(top:10,left:60,right:40),
                      child: Text("Name",style:TextStyle(fontSize: 18,color:Color.fromRGBO(82,93,92,1))),
                    )
                  ),
                  Container(
                    alignment: Alignment.center,
                    child:Padding(
                      padding: const EdgeInsets.only(top:10,left:40,right:40),
                      child: TextField(
                        onEditingComplete: ()=>FocusScope.of(context).nextFocus(),
                        controller: usernamecontroller,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical:10),
                          filled: true,
                          fillColor: Color.fromRGBO(246, 246, 246, 1),
                          prefixIcon: Icon(Icons.person_outline,color: Color.fromRGBO(82,93,92,1)),
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
                      padding: const EdgeInsets.only(top:10,left:60,right:40),
                      child: Text("Phone No.",style:TextStyle(fontSize: 18,color:Color.fromRGBO(82,93,92,1))),
                    )
                  ),
                  Container(
                    alignment: Alignment.center,
                    child:Padding(
                      padding: const EdgeInsets.only(top:10,left:40,right:40),
                      child: TextField(
                        onEditingComplete: ()=>FocusScope.of(context).nextFocus(),
                        controller: phonecontroller,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical:10),
                          filled: true,
                          fillColor: Color.fromRGBO(246, 246, 246, 1),
                          prefixIcon: Icon(Icons.phone),
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
                      padding: const EdgeInsets.only(top:10,left:60,right:40),
                      child: Row(
                        children: <Widget>[
                          Text("Password",style:TextStyle(fontSize: 18,color:Color.fromRGBO(82,93,92,1))),
                          Expanded(child: Container(),),
                          Visibility(
                            visible: dontMatch,
                            child: Text("Passwords don't match",style:TextStyle(color:Colors.red[400])),
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
                        controller: passwordcontroller,
                        obscureText: hide,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical:10),
                          filled: true,
                          fillColor: dontMatch ? Colors.red[100] : Color.fromRGBO(246, 246, 246, 1),
                          prefixIcon: Icon(Icons.lock_outline,color: Color.fromRGBO(82,93,92,1)),
                          suffixIcon:GestureDetector(
                            onTap: ()=>{
                              setState((){
                                hide = !hide;
                              })
                            },
                            child: Icon(hide ? Icons.visibility_off : Icons.visibility,color:Colors.black),), 
                            //Icon(Icons.visibility_off,color: Color.fromRGBO(218,218,218,1)),
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
                      padding: const EdgeInsets.only(top:10,left:60,right:40),
                      child: Text("Confirm Password",style:TextStyle(fontSize: 18,color:Color.fromRGBO(82,93,92,1))),
                    )
                  ),
                  Container(
                    alignment: Alignment.center,
                    child:Padding(
                      padding: const EdgeInsets.only(top:10,left:40,right:40),
                      child: TextField(
                        onEditingComplete: ()=>signin(),
                        controller: confirmcontroller,
                        obscureText: chide,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical:10),
                          filled: true,
                          fillColor: dontMatch ? Colors.red[100] : Color.fromRGBO(246, 246, 246, 1),
                          prefixIcon: Icon(Icons.lock_outline,color: Color.fromRGBO(82,93,92,1)),
                          suffixIcon:GestureDetector(
                            onTap: ()=>{
                              setState((){
                                chide = !chide;
                              })
                            },
                            child: Icon(chide ? Icons.visibility_off : Icons.visibility,color:Colors.black)), 
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
                        onPressed: ()=>signin(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Register",style:TextStyle(color:Colors.white,fontSize: 18)),
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
                        Text("Already have an account? ",style:TextStyle(fontSize:15,fontFamily: 'Mulish-Reg')),
                        GestureDetector(
                          onTap: ()=>Navigator.of(context).push(login()),
                          child: Text("Log in",style:TextStyle(fontSize:15))
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
                            onTap: null,
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
                    child: Image.asset('assets/bottom.png'),
                  )
                ],
              ),
            ),
            submit ? 
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
        )
      )
    );
  }
}
