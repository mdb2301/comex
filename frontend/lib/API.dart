import 'dart:convert';
import 'package:comex/Book.dart';
import 'package:comex/CustomUser.dart';
import 'package:comex/Fence.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

const url = "https://comex-api-mdb.herokuapp.com";

class APIResponse{
  int code;String message,fenceId;CustomUser user;dynamic book;List<Fence> fences;
  APIResponse({this.code,this.message,this.user,this.book,this.fenceId,this.fences});
}

class API{
  Future<APIResponse> getUser(String firebaseId) async {
    http.Response res = await http.post("$url/getuser",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,String>{
        "firebase_id":firebaseId
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==11){
          return APIResponse(code:0,message:"User found",user:CustomUser.fromJson(j));
        }else{
          return APIResponse(code:1,message:"${j["code"]}:${j["msg"]}");
        }
      }else{
        return APIResponse(code:1,message:"Response empty or invalid");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  Future<APIResponse> addUser(CustomUser user) async {
    http.Response res = await http.post("$url/adduser",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,dynamic>{
        "name":user.name,
        "firebase_id":user.firebaseId,
        "email":user.email,
        "fence_id":user.fenceId,
        "phone":user.phone
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==11){
          print(j["id"]);
          return APIResponse(code:0,message:"User added",user:CustomUser.fromJson(j));
        }else{
          if(j["code"]==14){
            return APIResponse(code:2,message:"Already exists");
          }else{
            return APIResponse(code:1,message:"Failed. ${j["code"]}:${j["msg"]}");
          }
        }
      }else{
        return APIResponse(code:1,message:"Response empty or invalid");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  Future<APIResponse> updatePhone(String firebaseId,String phone) async {
    http.Response res = await http.post("$url/updatephone",
        headers: <String,String>{
          'content-type':'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String,dynamic>{
          "firebase_id":firebaseId,
          "phone":phone
        })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        return APIResponse(code:j["code"],message:j["msg"]);
      }else{
        return APIResponse(code:1,message:"Response empty or invalid");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  Future<APIResponse> addBook(CustomUser user,BookAPIQuery book,int price) async {
    http.Response res = await http.post("$url/addbook",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,dynamic>{
        "title":book.title,
        "authors":book.authors,
        "etag":book.etag??"",
        "pages":book.pages,
        "description":book.description,
        "avg_rating":book.rating,
        "thumb_link":book.image,
        "google_link":book.infoLink,
        "price":price,
        "uploaded_by":user.firebaseId
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        print(j);
        if(j["code"]==20){
          print(j["id"]);
          return APIResponse(code:0,message:"Book added");
        }
        return APIResponse(code:1,message:j["msg"].toString());
      }else{
        return APIResponse(code:1,message:"Response empty or invalid.");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  Future<APIResponse> getBooksInFence(String firebaseId,String fenceId) async {
    http.Response res = await http.post("$url/booksinfence",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,String>{
        "firebase_id":firebaseId,
        "fence_id":fenceId
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==31){
          return APIResponse(code:0,message:"Books found",book:parseBooks(j["books"]));
        }else{
          print("${j["code"]}:${j["msg"]}");
          return APIResponse(code:1,message:"${j["code"]}:${j["msg"]}");
        }
      }else{
        print(res.body);
        return APIResponse(code:1,message:"Response empty or invalid");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  Future<APIResponse> getBooksByUser(String firebaseId) async {
    http.Response res = await http.post("$url/booksbyuser",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,String>{
        "firebase_id":firebaseId
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==31){
          return APIResponse(code:0,message:"Books found",book:parseBooks(j["books"]));
        }else{
          if(j["code"]==30){
            return APIResponse(code:2,message:"No Books");
          }
          print("${j["code"]}:${j["msg"]}");
          return APIResponse(code:1,message:"${j["code"]}:${j["msg"]}");
        }
      }else{
        print(res.body);
        return APIResponse(code:1,message:"Response empty or invalid");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  Future<APIResponse> getListings(String firebaseId) async {
    http.Response res = await http.post("$url/listings",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,String>{
        "firebase_id":firebaseId
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==31){
          List<BookAPIQuery> books = await parseBooks(j["books"]);
          return APIResponse(code:0,message:"Books found",book:books);
        }else{
          if(j["code"]==30){
            return APIResponse(code:2,message:"No Books");
          }
          print("${j["code"]}:${j["msg"]}");
          return APIResponse(code:1,message:"${j["code"]}:${j["msg"]}");
        }
      }else{
        print(res.body);
        return APIResponse(code:1,message:"Response empty or invalid");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  serverEntry(Map<String,dynamic> map) async {
    var user = await getUserName(map["uploaded_by"]);
    return BookAPIQuery(
        id: map["id"],
        title: map["title"],
        authors: map["authors"],
        pages: map["pages"],
        description: map["description"],
        uploadedOn: map["uploaded_on"],
        uploadedBy: user.name,
        uploadedPhone: user.phone,
        price: map["price"],
        rating: map["rating"],
        infoLink: map["infoLink"],
        image: map["image"],
        taken: map["taken"],
        etag: map["etag"]
    );
  }

  Future<List<BookAPIQuery>> parseBooks(List<dynamic> list) async {
    List<BookAPIQuery> books = List<BookAPIQuery>();
    for(var i=0;i<list.length;i++){
      BookAPIQuery book = await serverEntry(list[i]);
      books.add(book);
    }
    return books;
  }

  Future<APIResponse> getExchanges(String firebaseId) async {
    http.Response res = await http.post("$url/exchanges",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,String>{
        "firebase_id":firebaseId
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==31){
          return APIResponse(code:0,message:"Books found",book:parseBooks(j["books"]));
        }else{
          if(j["code"]==30){
            return APIResponse(code:2,message:"No Books");
          }
          print("${j["code"]}:${j["msg"]}");
          return APIResponse(code:1,message:"${j["code"]}:${j["msg"]}");
        }
      }else{
        print(res.body);
        return APIResponse(code:1,message:"Response empty or invalid");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  Future<APIResponse> exchange(String firebaseId,String bookId) async {
    http.Response res = await http.post("$url/exchange",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,String>{
        "firebase_id":firebaseId,
        "book_id":bookId
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==40){
          return APIResponse(code:0,message:"Successful");
        }else{
          if(j["code"]==41){
            return APIResponse(code:1,message:"No Book Found");
          }
          return APIResponse(code:1,message:"${j["code"]}:${j["msg"]}");
        }
      }else{
        print(res.body);
        return APIResponse(code:1,message:"Response empty or invalid");
      }
    }else{
      return APIResponse(code:1,message:"Request failed ${res.statusCode}");
    }
  }

  Future<APIResponse> checkFence() async {
    LocationData location = await determinePosition();
    if(location != null){
      http.Response res = await http.post("$url/checkfence",
        headers: <String,String>{
          'content-type':'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String,dynamic>{
          "latitude":location.latitude,
          "longitude":location.longitude
        })
      );
      if(res.statusCode==200){
        if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
          var j = json.decode(res.body);
          print("\n\n${j["code"]}\n\n");
          switch(j["code"]){
            case 60:
              return APIResponse(code:0,fenceId:j["fence_id"]);
            case 62:
              return APIResponse(code:61);
            case 61:
              return APIResponse(code:61,message:j["msg"]);
            default:
              return APIResponse(code:j["code"],message:j["msg"]);
          }
        }
      }
    }
    return APIResponse(code:1,message:"Failed");
  }

  Future<APIResponse> addFence(double lat1,double lon1,double lat2,double lon2, String name) async {
    http.Response res = await http.post("$url/addfence",
      headers: <String,String>{
        'content-type':'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,dynamic>{
        "name":name,
        "lat1":lat1,
        "lon1":lon1,
        "lat2":lat2,
        "lon2":lon2,        
      })
    );
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==50 || j["code"]==14){
          return APIResponse(code:0,fenceId:j["id"]);
        }else{
          return APIResponse(code:j["code"],message:j["msg"]??"");
        }
      }
    }
    return APIResponse(code:1,message:"Failed");
  }

  Future<LocationData> determinePosition() async {
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
    return await location.getLocation();   
  }

  Future<APIResponse> fetchFences() async {
    http.Response res = await http.post("$url/fetchfences");
    if(res.statusCode==200){
      if(res.body.isNotEmpty && !res.body.startsWith("<html>")){
        var j = json.decode(res.body);
        if(j["code"]==80){
          return APIResponse(code:0,fences:parseFences(j["fences"]));
        }
      }
    }
    return APIResponse(code:1);
  }

  parseFences(document){
    var fences = List<Fence>();
    for(var i=0;i<document.length;i++){
      fences.add(Fence.fromJson(document[i]));
    } 
    return fences;
  }
}

Future<CustomUser> getUserName(String firebaseId) async {
  final res = await API().getUser(firebaseId);
  if(res.code==0){
    return res.user;
  }else{
    return null;
  }
}
