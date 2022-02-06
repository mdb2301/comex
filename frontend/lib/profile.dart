import 'dart:async';

import 'package:comex/API.dart';
import 'package:comex/Authentication.dart';
import 'package:comex/CustomUser.dart';
import 'package:comex/MyExchanges.dart';
import 'package:comex/MyListings.dart';
import 'package:comex/Storage.dart';
import 'package:comex/main.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final CustomUser user;final String auth;
  ProfilePage({this.user,this.auth});
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfilePage> {
  CustomUser user;String auth;
  @override
  void initState() {
    user = widget.user;
    auth = widget.auth;
    getUser();
    super.initState();
  }

  getUser() async {
    APIResponse res = await API().getUser(user.firebaseId);
    if(res.code==0){
      setState(() {
        user = res.user;
      });
    }
  }

  Route listings(){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MyListings(user:user),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin: Offset(1.0,0.0),end: Offset.zero)),
          child: child,
        );
      },
    );
  }

  Route exchanges(){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MyExchanges(user:user),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin: Offset(1.0,0.0),end: Offset.zero)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(left:20,top:20),
                      child: GestureDetector(
                        onTap: ()=>Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back,size: 30,)
                      ),
                    )
                  ),                    
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top:40),
                child: Column(
                  children: <Widget>[
                    Container(
                      width:88,height:88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(44),
                        color: Color.fromRGBO(3, 163, 99, 1)
                      ),
                      child: Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Color.fromRGBO(8, 199, 68, 1),
                          child: user.name == null || user.name.length==0? Text("NA",style: TextStyle(color: Colors.white,fontSize: 30),) : Text(user.name[0]+user.name[1],style: TextStyle(color: Colors.white,fontSize: 30),),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(user.name,style: TextStyle(fontSize: 20),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:20),
                      child: Container(
                        width:150,height:50,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(246, 246, 246, 1),
                          borderRadius: BorderRadius.circular(25)
                        ),
                        child: Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('assets/dollar_2.png',scale: 2.8,),
                              SizedBox(width:10),
                              Text(user.coins.toString(),style: TextStyle(fontSize: 15),)
                            ],
                          )
                        )
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(user.listings.toString(),style: TextStyle(fontSize: 30,color: Color.fromRGBO(67,67,67,1)),),Text("LISTINGS",style: TextStyle(color: Color.fromRGBO(82,93,92,1))) //82 93 92
                            ],
                          ),
                          SizedBox(width: 60,),
                          Column(
                            children: <Widget>[
                              Text(user.exchanges.toString(),style: TextStyle(fontSize: 30,color: Color.fromRGBO(67,67,67,1)),),Text("EXCHANGES",style: TextStyle(color: Color.fromRGBO(82,93,92,1))) //82 93 92
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height:30),
                    Option(icon: Icon(Icons.list),text: "My Listings",ontap:()=>Navigator.of(context).push(listings())),
                    Option(icon: Image.asset('assets/trans.png',scale: 2.5,),text: "My Exchanges",ontap:()=>Navigator.of(context).push(exchanges())),
                    Visibility(
                      visible: !user.updated,
                      child:Option(icon: Image.asset('assets/add_phone.png',scale: 8,),text: "Add Phone Number",ontap:()=>Navigator.of(context).push(settings())),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:60,bottom:30),
                      child: Center(
                        child: GestureDetector(
                          onTap: logout,
                          child: Column(
                            children: <Widget>[
                              Image.asset('assets/logout.png',scale: 2.4,),
                              SizedBox(height:10),
                              Text("Log Out")
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ]
          ),
        )
      )
    );
  }

  Route settings(){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => PhoneUpdate(firebaseId: user.firebaseId),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin:Offset(-1,0),end:Offset.zero)),
          child: child,
        );
      },
    );
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

  logout() async {
    print(widget.auth);
    
    switch(widget.auth){
      case "email":
        Email().signOut();
        if(await Storage().clear()){
          Navigator.of(context).pushAndRemoveUntil(login(), (route) => false);
        }
        break;
      case "google":
        Email().signOut();
        if(await Storage().clear()){
          Navigator.of(context).pushAndRemoveUntil(login(), (route) => false);
        }        
        break;
      case "facebook":
        Email().signOut();
        if(await Storage().clear()){
          Navigator.of(context).pushAndRemoveUntil(login(), (route) => false);
        }
        break;
    }

  }
}

class Option extends StatelessWidget {
  final icon,text,ontap;
  Option({this.icon,this.text,this.ontap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top:30,left:25,right:20),
      child: GestureDetector(
        onTap: ontap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            icon,
            SizedBox(width:30),
            Text(text,style: TextStyle(fontSize: 15),),
            Expanded(child: Container(),),
            Icon(Icons.arrow_forward_ios,color: Color.fromRGBO(8, 199, 68, 1),size: 20)
          ],
        )
      ),
    );
  }
}

class PhoneUpdate extends StatefulWidget {
  final firebaseId;
  PhoneUpdate({this.firebaseId});
  @override
  _PhoneUpdateState createState() => _PhoneUpdateState();
}

class _PhoneUpdateState extends State<PhoneUpdate> {
  TextEditingController phonecontroller;bool error,loading;
  @override
  void initState() {
    error = false;
    loading = false;
    phonecontroller = TextEditingController(text:"+91");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Center(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        alignment: Alignment.topLeft,
                        child:Padding(
                          padding: const EdgeInsets.only(top:30,left:50),
                          child: Text("Update Phone Number",style:TextStyle(fontSize: 30,color:Color.fromRGBO(69, 69, 69, 1))),
                        )
                    ),
                    SizedBox(height:100),
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
                          padding: const EdgeInsets.only(top:25,left:40,right:40),
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
                    Visibility(
                      visible: error,
                      child: Padding(
                        padding: EdgeInsets.only(top:20),
                        child: Text("Invalid phone number",style:TextStyle(color:Colors.red))
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:50),
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
                            onPressed: update,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Update",style:TextStyle(color:Colors.white,fontSize: 18)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:10),
                                  child: Icon(Icons.done,color:Colors.white),
                                )
                              ],
                            ),
                          )
                      ),
                    ),
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
            )
          )
        ),
      ),
    );
  }

  update() async {
    setState(() {
      loading=true;
    });
    if(phonecontroller.value.text.trim() != "" && phonecontroller.value.text.trim()!="+91"){
      print(phonecontroller.value.text);
      print(widget.firebaseId);
      APIResponse res = await API().updatePhone(widget.firebaseId,phonecontroller.value.text.trim());
      switch(res.code){
        case 70:
          Timer(Duration(seconds: 2),(){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
          showDialog(
            context: context,
            builder: (context){
              return Dialog(
                backgroundColor: Colors.white,
                child: Container(
                  width: 200,height:150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Phone Number Updated!"),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                            width:30,height:30,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(8, 199, 68, 1),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Center(child: Icon(Icons.check,color:Colors.white))
                        ),
                      )
                    ],
                  )
                ),
              );
            }
          );
          break;
        case 12:
          print(res.message);
          setState(() {
            error = true;
          });
          break;
        default:
          print(res.message);
          Timer(Duration(seconds: 4),(){
            Navigator.of(context).pop();
          });
          showDialog(
            context: context,
            builder: (context){
              return Dialog(
                backgroundColor: Colors.white,
                child: Container(
                  width: 200,height:150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Failed to update"),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                            width:30,height:30,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Center(child: Icon(Icons.check,color:Colors.white))
                        ),
                      )
                    ],
                  )
                ),
              );
          }
        );
      }
    }else{
      setState(() {
        error = true;
      });
    }
  }
}
