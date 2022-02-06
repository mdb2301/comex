import 'dart:async';
import 'dart:convert';
import 'package:comex/API.dart';
import 'package:http/http.dart' as http;
import 'package:comex/Book.dart';
import 'package:comex/CustomUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewListingPage extends StatefulWidget{
  final CustomUser user;
  NewListingPage({this.user});
  NewListing createState()=>NewListing();
}

class NewListing extends State<NewListingPage>{
  bool searched; List<BookAPIQuery> bookdata;
  int price;
  TextEditingController ctrl,textctrl;
  @override
  void initState(){
    searched = false;
    bookdata = List<BookAPIQuery>();
    ctrl = TextEditingController();
    price = 120;
    textctrl = TextEditingController(text: price.toString());
    super.initState();
  }

  Widget build(BuildContext context){
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 5,bottom:5),
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
                            Container(                 
                              child: Padding(
                              padding: const EdgeInsets.only(right:20,top:20),
                              child: GestureDetector(
                                onTap: null,
                                child: Icon(Icons.bookmark_border,size:30),
                                // on tap Icons.bookmark
                              ),
                            )
                          )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top:60,left:45,right:20,bottom:17),
                          child: Container(  
                            child: TextField(
                              controller: ctrl,
                              onEditingComplete: searchBook,
                              decoration: InputDecoration(
                                fillColor: Color.fromRGBO(69,69,69,1),
                                border: InputBorder.none,
                                hintText: "Search a Book",
                                hintStyle: TextStyle(color: Color.fromRGBO(69,69,69,0.5)),
                                suffixIcon: Container(
                                  width:40,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black38),
                                    borderRadius: BorderRadius.circular(23)
                                  ),
                                  child: GestureDetector(
                                    onTap: searchBook,
                                    child: Icon(Icons.search),
                                  ),
                                ) 
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical:8,horizontal:12),
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: bookdata.length, 
                            itemBuilder: (context,i){
                              return GestureDetector(
                                onTap: ()=>details(i),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: i==0 ? Border() : Border(top:BorderSide(color:Colors.black38))
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(height:130,child: Center(child: Image.network(bookdata[i].image,scale:1.6))),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top:15,left:15,right:15),
                                            child: Container(width:200,child: Text(bookdata[i].title,style:TextStyle(fontSize: 16))),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(bottom:15,left:15,right:15),
                                            child: Container(width:200,child: Text(bookdata[i].authors,style:TextStyle(color: Color.fromRGBO(69,69,69,0.5)))),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        )
                      ]
                    ),
                  ),
                ),
              ]  
            ),
        )
      );         
  }

  details(int i){
    showDialog(
      context: context,
      builder: (context){
        return Dialog(
          child: SingleChildScrollView(child: BookResult(bookdata:bookdata[i],user:widget.user))
        );
      }
    );
  }

  getBorder(int i,int total){
    final side = BorderSide(color:Color.fromRGBO(69,69,69,0.5),width:0.5);
    if(i%2==0){ //left
      if(i==0 || i==1){ //top
        return Border(right:side,bottom:side);
      }else{
        if(i==total-1 || i==total-2){
          return Border(right:side,top:side);
        }
        return Border(right:side,top:side,bottom:side);
      }
    }else{ //right
      if(i==0 || i==1){ //top
        return Border(left:side,bottom:side);
      }else{
        if(i==total-1 || i==total-2){
          return Border(left:side,top:side);
        }
        return Border(left:side,top:side,bottom:side);
      }
    }
  }

  searchBook() async {
    setState(() {
      bookdata = List<BookAPIQuery>();
      FocusScope.of(context).unfocus();
    });
    //final response = await http.get('https://www.googleapis.com/books/v1/volumes?q=$queryText&maxResults=1');
    final response = await http.get('https://www.googleapis.com/books/v1/volumes?q=${ctrl.value.text}');
    if(response.statusCode==200){
      try{
        final rawdata = json.decode(response.body)["items"];
        print(rawdata[0]);
        for(var i=0;i<rawdata.length;i++){
          setState(() {
            bookdata.add(fromJson(rawdata[i]));
          });
        }
        setState(() {
          searched = true;
          ctrl.clear();
        });
      }catch(e){
        print("Book not found. Error message: "+ e.toString());
      }
    }
  }

  fromJson(map){
    var vinfo = map["volumeInfo"];
    return BookAPIQuery(
      title: vinfo['title'],
      authors: (vinfo['authors'] as List).join(', ').replaceAll('Authors', ''),
      image: split(vinfo['imageLinks']['smallThumbnail']),
      infoLink: vinfo['infoLink'],
      description: vinfo['description'],
      pages: vinfo['pageCount'],
      rating: vinfo['averageRating'],
      etag: vinfo["etag"]
    );
  }

  split(String link){
    link = link.split(":")[1];
    return "https:"+link;
  }
}


class BookResult extends StatefulWidget {
  final BookAPIQuery bookdata;
  final int price;final CustomUser user;
  BookResult({this.bookdata,this.price,this.user});
  @override
  _BookResultState createState() => _BookResultState();
}

class _BookResultState extends State<BookResult> {
  BookAPIQuery bookdata;int price;TextEditingController textctrl;CustomUser user;bool error,inProgress;
  @override
  void initState(){
    super.initState();
    bookdata = widget.bookdata;
    price = 12;
    error = false;
    inProgress = false;
    textctrl = TextEditingController(text: price.toString());
    user = widget.user;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top:20,bottom:20),
      child: Container(  
        child:Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
              child:  bookdata.image != null ? Image.network(bookdata.image,scale:1) : Image.asset('assets/book.png',scale: 3.5,)
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(width:180,child: Center(child: Text(bookdata.title,textAlign: TextAlign.center,style:TextStyle(fontSize: 25)))),
                  Container(width:180,child: Center(child: Text(bookdata.authors??"N/A",textAlign: TextAlign.center,style:TextStyle(fontSize:15,color: Color.fromRGBO(69,69,69,0.5))))),                                               
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top:20,left:20,right:10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(bookdata.rating.toString()??"N/A",style: TextStyle(fontSize:25),),
                      Text("Rating",style:TextStyle(fontSize: 15,color: Color.fromRGBO(69, 69, 69, 0.8)))
                    ],
                  ),
                  SizedBox(width:35),
                  Container(width:2,height:50,color: Color.fromRGBO(69, 69, 69, 0.5),),
                  SizedBox(width:35),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(bookdata.pages.toString()??"N/A",style: TextStyle(fontSize:25),),
                      Text("Pages",style:TextStyle(fontSize: 15,color: Color.fromRGBO(69, 69, 69, 0.8)))
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top:50,left:30,right:30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("About",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  SizedBox(height: 10,),
                  Text(bookdata.description??"N/A",style: TextStyle(color: Color.fromRGBO(69, 69, 69, 0.8))),
                  SizedBox(height:20),
                  GestureDetector(
                    onTap: openUrl,
                    child: Text("Read more",style: TextStyle(color: Colors.blue[300]),),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top:30,left:20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: ()=>{
                      setState((){
                        price--;
                        textctrl.text = price.toString();
                      })
                    },
                    child: Container(
                      child: Icon(Icons.remove,size: 30,color: Color.fromRGBO(246,246,246,1),),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color.fromRGBO(171,171,171,0.9)
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left:20,right:5),
                    child: Image.asset('assets/dollar_2.png',scale:4),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left:5,right:10),
                    child: Container(
                      width: 40,
                      child: Center(
                        child: TextField(
                          onChanged: (value) => {
                            setState((){
                              price = int.parse(value);
                            })
                          },
                          controller: textctrl,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 20,color: Colors.black87),
                          decoration: InputDecoration(
                            border: InputBorder.none
                          ),
                        ),
                      ),
                    )
                  ),
                  GestureDetector(
                    onTap: ()=>{
                      setState((){
                        price++;
                        textctrl.text = price.toString();
                      })
                    },
                    child: Container(
                      child: Icon(Icons.add,size: 30,color: Color.fromRGBO(246,246,246,1)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color.fromRGBO(171,171,171,0.9)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 80,vertical: 30),
              child: GestureDetector(
                onTap: listBook,
                child: Container(
                  height: 50,
                  alignment:Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [Color.fromRGBO(3, 163, 99, 1),Color.fromRGBO(8, 199, 68, 1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right:10,left:10),
                          child: Text("List for ",style:TextStyle(color:Colors.white)),
                        ),
                        Image.asset('assets/dollar_2.png',scale: 4,),
                        Padding(
                          padding: EdgeInsets.only(right:10,left:5),
                          child: Text(price.toString(),style:TextStyle(color:Colors.white)),
                        ),
                      ],
                    ),
                  )
                ),
              ),
            ),
            inProgress ? 
            Center(child: Container(width:20,height:20,child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(3, 163, 99, 1)),)))
            :
            error ? 
            Padding(
              padding: EdgeInsets.only(top:10,bottom:10),
              child: Center(child: Text("Error uploading book. Please try again later.",style: TextStyle(color: Colors.red,fontSize: 12),),)
            )
            : Container()
            
          ], 
        ) 
      )
    );
  }

  openUrl() async {
    if(await canLaunch(bookdata.infoLink)){
      await launch(bookdata.infoLink);
    }
  }

  listBook() {
    setState(() {
      inProgress = true;
    });
    API().addBook(widget.user,bookdata,price).then((res){
      print(res.code);
      if(res.code==0){
        done();
      }else{
        print(res.message);
        setState(() {
          error = true;
          inProgress = false;
        });
      } 
    });   
  }

  done(){
    setState(() {
      inProgress = false;
    });
    Timer(Duration(seconds: 2),(){
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
                Text("Book Added Successfully!"),
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
  }
}