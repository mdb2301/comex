import 'package:flutter/material.dart';
import 'CustomUser.dart';
import 'dart:async';
class Settings extends StatefulWidget {
  final CustomUser user;
  Settings({this.user});
  @override
  MySettingsState createState() => MySettingsState();
}

class MySettingsState extends State<Settings> {
  CustomUser user;
  Timer timer;Widget altwidget;
  @override
  initState(){
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    altwidget = Container(width:MediaQuery.of(context).size.width,child:Center(child: Container(width:50,height:50,child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(3, 163, 99, 1)),),),));
    return Scaffold(
      body:SingleChildScrollView(
        child: Container()
      )
    );
  }
}

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}