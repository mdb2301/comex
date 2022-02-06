import 'package:google_maps_flutter/google_maps_flutter.dart';

class Fence{
  final id,name;
  final LatLng point1,point2;
  Fence({this.id,this.name,this.point1,this.point2});

  factory Fence.fromJson(Map<String,dynamic> json){
    return Fence(
      id: json["id"],
      name:json["name"],
      point1: LatLng(json["point1"]["latitude"],json["point1"]["longitude"]),
      point2: LatLng(json["point2"]["latitude"],json["point2"]["longitude"])
    );
  }
}