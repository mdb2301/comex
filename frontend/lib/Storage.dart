import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageResponse{
  String message,firebaseId,type;int code;bool isLoggedIn;
  StorageResponse({this.code,this.message,this.firebaseId,this.isLoggedIn,this.type});
}

class Encryption{
  encrypt(String data){
    final enc = Encrypter(AES(Key.fromUtf8("2OmuvKIRKlVHf@4wGXAS61cyl&32hB!e")));
    final iv = IV.fromUtf8("jrjrZF1ljSty@N@c");
    return enc.encrypt(data,iv:iv).base64;
  }
  decrypt(String data){
    final enc = Encrypter(AES(Key.fromUtf8("2OmuvKIRKlVHf@4wGXAS61cyl&32hB!e")));
    final iv = IV.fromUtf8("jrjrZF1ljSty@N@c");
    return enc.decrypt64(data,iv:iv);
  }
}

class Storage{
  Future<StorageResponse> write(String firebaseId, String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool res = await pref.setBool("loggedIn", true);
    if(res){
      res = await pref.setString("type", type);
      if(res){
        res = await pref.setString("uid", Encryption().encrypt(firebaseId));
        if(res){
          return StorageResponse(code:0,message:"Stored");
        }
      }
    }
    return StorageResponse(code:1,message:"Failed");
  }

  Future<StorageResponse> read() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool loggedIn = pref.getBool("loggedIn");
    String firebaseId,type;
    if(loggedIn != null){
      firebaseId = Encryption().decrypt(pref.getString("uid"));
      if(firebaseId!= null && firebaseId.isNotEmpty){
        type = pref.getString("type");
        return StorageResponse(isLoggedIn: true,firebaseId:firebaseId,type:type);
      }
    }
    return StorageResponse(isLoggedIn:false);
  }

  Future<bool> clear() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await pref.clear();
  }

}