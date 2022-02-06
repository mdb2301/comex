import 'dart:async';

import 'package:comex/API.dart';
import 'package:comex/Book.dart';
import 'package:comex/CustomUser.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyListings extends StatefulWidget {
  final CustomUser user;
  MyListings({this.user});
  @override
  _MyListingsState createState() => _MyListingsState();
}

class _MyListingsState extends State<MyListings> {
  List<BookAPIQuery> books;bool loading;
  @override
  void initState() {
    books = List<BookAPIQuery>();
    getBooks();
    Timer(Duration(seconds:10),(){
      setState(() {
        loading = false;
      });
    });
    loading = true;
    super.initState();
  }

  Route details(int index, BookAPIQuery book){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ListingDetailsPage(index:index,book:book,user:widget.user),
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
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: GestureDetector(
                        onTap: ()=>Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back,size: 30,)
                      ),
                    ),
                    Expanded(child:Container()),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Text("My Listings",style:TextStyle(fontSize: 20))
                    ),
                  ],
                ), 
                loading ? 
                Container(height:MediaQuery.of(context).size.height,width:MediaQuery.of(context).size.width,child: Center(child: Container(width:50,height:50,child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(3, 163, 99, 1)),))))
                : books.length==0 ?   
                  Container(
                    height:MediaQuery.of(context).size.height,width:MediaQuery.of(context).size.width,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical:20),
                            child: Text("No result"),
                          ),
                          GestureDetector(
                            onTap: refresh,
                            child: Container(
                              width:40,height:40,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(245,245,245,1),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Icon(Icons.refresh)
                            )
                          )
                        ],
                      )
                    ),
                  )               
                : Padding(
                  padding: EdgeInsets.symmetric(vertical:25),
                  child: RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: books.length,
                      itemBuilder: (context,index){
                        print(books[index].id);
                        return GestureDetector(
                          onTap: ()=>Navigator.of(context).push(details(index,books[index])),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top:8,bottom:8,left:14),
                                  child: Hero(
                                    tag: index.toString(),
                                    child: Container(
                                      width: 80,height:100,
                                      child: Image.network(books[index].image,scale:1.8)
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top:8,bottom:8,left:33),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(width:200,child: Text(books[index].title,style:TextStyle(fontSize: 16))),
                                      Container(width:200,child: Text(books[index].authors,style:TextStyle(color: Color.fromRGBO(69,69,69,0.5)))),
                                      SizedBox(height:10),
                                      Container(width:200,child: Text(books[index].uploadedOn,style:TextStyle(color: Color.fromRGBO(69,69,69,0.5)))),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left:10),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset("assets/dollar_2.png",scale:2.5),
                                      Text(books[index].price.toString(),style: TextStyle(fontSize: 20),),
                                      Text("COINS")
                                    ],
                                  )
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }

  // ignore: missing_return
  Future<void> refresh() async {
    Timer(Duration(seconds:10),(){
      setState(() {
        loading = false;
      });
    });
    setState(() {
      loading = true;
    });
    await getBooks();
  }

  getBooks() async {
    APIResponse res = await API().getListings(widget.user.firebaseId);
    if(res.code==0){
      setState(() {
        books = res.book;
      });
    }
  }
  split(String link){
    link = link.split(":")[1];
    return "https:"+link;
  }
}

class ListingDetailsPage extends StatefulWidget {
  final BookAPIQuery book;final CustomUser user;
  final int index;
  ListingDetailsPage({this.index,this.book,this.user});
  @override
  ListingDetailsState createState() => ListingDetailsState();
}

class ListingDetailsState extends State<ListingDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView ( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical:12),
                          child: Hero(
                            tag: widget.index.toString(),
                            child: Image.network(
                              widget.book.image,
                              scale: 1.5,
                            ),
                          ),
                        ),
                        Container(
                          width:290,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left:20),
                                child: Text(widget.book.title,textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 25)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top:8,bottom:8,left:20),
                                child: Text(widget.book.authors??"N/A",style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1),fontWeight: FontWeight.w700)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom:10,left:20),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right:8,top:8,bottom:8),
                                      child: Image.asset('assets/dollar_2.png',scale: 4.2),
                                    ),
                                    Text(widget.book.price.toString(),style: TextStyle(color: Color.fromRGBO(69, 69, 69, 0.69),fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left:20),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text:"Listed On: ",style:TextStyle(color:Color.fromRGBO(69,69,69,0.96),fontSize:12,fontWeight:FontWeight.bold)),
                                      TextSpan(text:widget.book.uploadedOn,style:TextStyle(color:Color.fromRGBO(69,69,69,0.69),fontSize:12))
                                    ]
                                  )
                                )
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(        
                    width:MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight:Radius.circular(40),
                          topLeft: Radius.circular(40)
                          ),
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top:60),
                          width:300,height:300,
                          child: QrImage(
                            data: widget.book.id + "_" + widget.book.price.toString(),
                            version:4
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top:50,bottom:120),
                          child: Text("Scan my code to exchange",style:TextStyle(color:Colors.black45,fontSize:17)),
                        ),
                      ],
                    ),
                  ),  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}