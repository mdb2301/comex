class CustomUser{
  String name,email,firebaseId,fenceId, dateJoined,phone;
  int coins,listings,exchanges;
  bool updated;
  CustomUser({this.name,this.email,this.phone,this.firebaseId,this.fenceId,this.coins,this.listings,this.exchanges,this.updated,this.dateJoined});

  factory CustomUser.fromJson(Map<String,dynamic> json){
    return CustomUser(
      name: json["name"],
      email: json["email"],
      firebaseId:json["firebase_id"],
      fenceId:json["fence_id"],
      phone: json["phone"],
      coins:json["coins"],
      listings:json["listings"],
      exchanges:json["exchanges"],
      updated:json["updated"],
      dateJoined: json["date_joined"].toString()
    );
  }
}
