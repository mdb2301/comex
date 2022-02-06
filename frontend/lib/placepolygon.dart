import 'package:comex/API.dart';
import 'package:comex/CustomUser.dart';
import 'package:comex/Storage.dart';
import 'package:comex/home.dart';
import 'package:flutter/material.dart';
import 'package:google_map_polyutil/google_map_polyutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacePolygonBody extends StatefulWidget {
  final CustomUser user;
  final dynamic auth;
  final LatLng location;
  PlacePolygonBody({this.user,this.auth,this.location});  
  @override
  State<StatefulWidget> createState() => PlacePolygonBodyState();
}

class PlacePolygonBodyState extends State<PlacePolygonBody> {
  PlacePolygonBodyState();
  int count;bool submit,error;FocusNode node;TextEditingController namecontroller;
  GoogleMapController controller;
  Set<Polygon> polygons,previous;
  List<LatLng> points;List<String> names;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void initState() {
    points = List<LatLng>();
    count = 0;
    polygons = Set<Polygon>();
    node = FocusNode();
    namecontroller = TextEditingController();
    submit = false;
    error = false;
    getFences();
    super.initState();
  }

  getFences() async {
    names = List<String>();
    previous = Set<Polygon>();
    var res = await API().fetchFences();
    if(res.code==0){
      for(var i=0;i<res.fences.length;i++){
        var polygon = [
          LatLng(res.fences[i].point1.latitude,res.fences[i].point1.longitude),
          LatLng(res.fences[i].point1.latitude,res.fences[i].point2.longitude),
          LatLng(res.fences[i].point2.latitude,res.fences[i].point2.longitude),
          LatLng(res.fences[i].point2.latitude,res.fences[i].point1.longitude)
        ];
        setState(() {
          previous.add(Polygon(
              polygonId: PolygonId("polygon_id_$count"),
              points: polygon,
              strokeColor: Colors.green,
              strokeWidth: 5,
              fillColor: Colors.yellow.withOpacity(0.5)
          ));
          names.add(res.fences[i].name);
        });
      }
    }
    setState(() {
      submit = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  showPoints(){
    var polygon = [
      LatLng(points[0].latitude,points[0].longitude),
      LatLng(points[0].latitude,points[1].longitude),
      LatLng(points[1].latitude,points[1].longitude),
      LatLng(points[1].latitude,points[0].longitude)
    ];
    setState(() {
      polygons.add(Polygon(
          polygonId: PolygonId("polygon_id_$count"),
          points: polygon,
          strokeColor: Colors.yellow,
          strokeWidth: 5,
          fillColor: Colors.yellow.withOpacity(0.5)
      ));
    });
  }

  handlePoint(point) async {
    if(polygons.length==1){
      print("Reseting");
      setState(() {
        polygons = Set<Polygon>();
        points = List<LatLng>();
      });
    }else{
      final pgs = previous.toList();
      bool existing = false;
      for(var i=0;i<pgs.length;i++){
        if(await GoogleMapPolyUtil.containsLocation(point:point, polygon:pgs[i].points)){
          setState(() {
            namecontroller.text = names[i];
            points = pgs[i].points;
            existing = true;
          });
        }
      }
      if(!existing){
        setState(() {
          namecontroller.text = "";
        });
        print("Adding point $point");
        switch(points.length){
          case 0:
            setState(() {
              points.add(point);
            });
            break;
          case 1:
            setState(() {
              points.add(point);
              showPoints();
              node.requestFocus();
            });
            break;
          case 2:
            setState(() {
              points[1] = point;
              showPoints();
              node.requestFocus();
            });
            break;
          default:
            break;
        }
      }
    }

  }

  submitAndContinue() async {
    setState(() {
      node.unfocus();
      submit = true;
    });
    if(namecontroller.value.text==null || namecontroller.value.text==""){
      setState(() {
        error = true;
        submit = false;
      });
    }else{
      APIResponse res = await API().addFence(points[0].latitude,points[0].longitude,points[1].latitude,points[1].longitude,namecontroller.value.text.trim());
      print("\n\n${res.code}\n\n");
      if(res.code==0){
        widget.user.fenceId = res.fenceId;
        APIResponse r = await API().addUser(widget.user);
        if(r.code==0){
          final storage = Storage();
          final storageres = await storage.write(r.user.firebaseId,widget.auth);
          if(storageres.code==1){
            Navigator.of(context).push(home(res.user,widget.auth));
          }
          Navigator.of(context).push(home(r.user,widget.auth));
        }else{
          print("Error registering"+res.message);
          widget.auth.deleteUser();
        }
        setState(() {
          submit = false;
        });
      }
    }
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async =>false,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: GoogleMap(
                      compassEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: widget.location,
                        zoom: 18.0,
                      ),
                      polygons: polygons.length==0 ? previous : polygons,
                      onMapCreated: _onMapCreated,
                      onTap: handlePoint
                    ),
                  ),
                ),
              ),
              Positioned(
                top:10,
                left:MediaQuery.of(context).size.width*0.05,
                child: Container(
                  width:MediaQuery.of(context).size.width*0.9,
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(
                      blurRadius: 10,
                      color: Colors.black38,
                      offset: Offset(2,2)
                    )],
                    color:Colors.white,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  padding: EdgeInsets.symmetric(vertical:17,horizontal:5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: namecontroller,
                          focusNode: node,
                          onEditingComplete: ()=>FocusScope.of(context).nextFocus(),
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            errorText: error ? "Name cannot be empty" : "",
                            hintText: "Name",
                            contentPadding: EdgeInsets.symmetric(vertical:10,horizontal:17),
                            filled: true,
                            fillColor: Color.fromRGBO(246, 246, 246, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                            ), 
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: 100,
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
                              onPressed: (){
                                print("Clear");
                                getFences();
                                setState(() {
                                  submit = true;
                                  points = List<LatLng>();
                                  polygons = Set<Polygon>();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Clear",style:TextStyle(color:Colors.white,fontSize: 18)),
                              ),
                            )
                          ),
                          Container(
                            width: 100,
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
                              onPressed: ()=>submitAndContinue(),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Done",style:TextStyle(color:Colors.white,fontSize: 18)),
                              ),
                            )
                          ),
                        ],
                      ),
                      SizedBox(height:10),
                      Center(
                        child:Text("(Tap to place points)",style: TextStyle(fontStyle:FontStyle.italic,color:Colors.black54),)
                      )
                    ],
                  ),
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
          ),
        ),
      ),
    );
  }
}