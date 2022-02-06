import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:comex/API.dart';
import 'package:comex/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'Book.dart';
import 'NewListingPage.dart';
import 'CustomUser.dart';

class Home extends StatefulWidget{
  final CustomUser user;final dynamic auth;
  Home({this.user,this.auth});
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>{
  CustomUser user;
  @override
  void initState(){
    user = widget.user;
    getUser();
    getBooks();
    super.initState();
  }

  getUser() async {
    APIResponse res = await API().getUser(user.firebaseId);
    if(res.code==11){
      setState(() {
        user = res.user;
      });
      print(user.fenceId);
    }
  }

  Route details(BookAPIQuery book,int index){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => BookDetailsPage(book:book,index:index,user:widget.user),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin: Offset(1.0,0.0),end: Offset.zero)),
          child: child,
        );
      },
    );
  }
  Route profile(){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(user:widget.user,auth:widget.auth),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin: Offset(1.0,0.0),end: Offset.zero)),
          child: child,
        );
      },
    );
  }

  Route newList(){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => NewListingPage(user:widget.user),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin: Offset(1.0,0.0),end: Offset.zero)),
          child: child,
        );
      },
    );
  }

  Route scanner(){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => QRScanner(user:widget.user),
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return SlideTransition(
          position: animation.drive(Tween(begin: Offset(1.0,0.0),end: Offset.zero)),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: ()=>Navigator.of(context).push(scanner()),
                          child: Image.asset('assets/qr-text.png',scale:4.2)
                        ),
                      ),
                      Expanded(child: Container(),),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: GestureDetector(
                          onTap: ()=>Navigator.of(context).push(profile()),
                          child: Hero(
                            tag: "profile_img",
                            child: Container(
                              width:45,height:45,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(8, 199, 68, 1),
                                borderRadius: BorderRadius.circular(25)
                              ),
                              alignment: Alignment.topLeft,
                              child: Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color.fromRGBO(8, 199, 68, 1),
                                  child: user.name == null || user.name.length==0? Text("NA",style: TextStyle(color: Colors.white,fontSize:15),) : Text(user.name[0]+user.name[1],style: TextStyle(color: Colors.white,fontSize:15),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:8,left:26,right:26,bottom:17),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search a Book",
                        hintStyle: TextStyle(color: Color.fromRGBO(69,69,69,0.3)),
                        prefixIcon: Icon(Icons.search) 
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top:20,left:10,right:10),
                        child: RefreshIndicator(
                          onRefresh: refresh,
                          child: FutureBuilder(
                            future: getBooks(),
                            builder: (context,snapshot){
                              if(snapshot.connectionState==ConnectionState.done){
                                if(snapshot.hasData){
                                  return getListView(snapshot.data);
                                }else{
                                  return getEmpty();
                                }
                              }else{
                                return Center(child: Container(width:50,height:50,child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(3, 163, 99, 1)),)));
                              }
                            },
                          )
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                bottom:10,left:100,right:100,
                child: GestureDetector(
                  onTap: ()=>Navigator.of(context).push(newList()),
                  child: Container(
                    height: 48,
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
                            child: Text("New Listing",style:TextStyle(color:Colors.white)),
                          ),
                          Icon(Icons.add,size: 25,color: Colors.white)
                        ],
                      ),
                    )
                  ),
                )
              )
            ],
          )
        ),
      ),
    );
  }

  getEmpty(){
    return Container(
      width:MediaQuery.of(context).size.width,
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
    );
  }

  getListView(data){
    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context,index){
        return Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: GestureDetector(
            onTap: ()=>Navigator.of(context).push(details(data[index],index)),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:8,bottom:8,left:14),
                  child: Hero(
                    tag: index.toString(),
                    child: Container(
                        width: 80,height:100,
                        child: Image.network(data[index].image,scale:1.8)
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:8,bottom:8,left:30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(width:200,child: Text(data[index].title,style:TextStyle(fontSize: 16))),
                      Container(width:200,child: Text(data[index].authors,style:TextStyle(color: Color.fromRGBO(69,69,69,0.5)))),
                      Padding(
                        padding: EdgeInsets.only(top:20),
                        child: Container(width:180,child: Text("Listed by:",style:TextStyle(color: Color.fromRGBO(69,69,69,0.9)))),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top:8,bottom:8),
                            child: Container(
                              width:24,height:24,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(8, 199, 68, 1),
                                  borderRadius: BorderRadius.circular(25)
                              ),
                              alignment: Alignment.topLeft,
                              child: Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color.fromRGBO(8, 199, 68, 1),
                                  child: data[index].uploadedBy == null || data[index].uploadedBy.length==0? Text("NA",style: TextStyle(color: Colors.white,fontSize:15),) : Text(data[index].uploadedBy[0]+data[index].uploadedBy[1],style: TextStyle(color: Colors.white,fontSize:15),),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top:8,left:8,bottom:8),
                              child: Text(data[index].uploadedBy,style: TextStyle(color: Color.fromRGBO(69,69,69,0.95)),)
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left:10),
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/dollar_2.png",scale:2.5),
                        Text(data[index].price.toString(),style: TextStyle(fontSize: 20),),
                        Text("COINS")
                      ],
                    )
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void>refresh() async{
    print("refresh");
    setState(() { });
    getBooks();
  }

  Future<List<BookAPIQuery>> getBooks() async {
    APIResponse res = await API().getBooksInFence(widget.user.firebaseId,widget.user.fenceId);
    if(res.code==0){
      return res.book;
    }
    return null;
  }
}

class BookDetailsPage extends StatefulWidget {
  final BookAPIQuery book;final CustomUser user,uploadedBy;
  final int index;
  BookDetailsPage({this.index,this.book,this.user,this.uploadedBy});
  @override
  BookDetailsState createState() => BookDetailsState();
}

class BookDetailsState extends State<BookDetailsPage> {
  BookAPIQuery book;
  @override
  void initState() {
    book = widget.book;
    print("Title: "+book.title);
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
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical:10),
                      child: Hero(
                        tag: widget.index.toString(),
                        child: Container(
                          width: 80,height:100,
                          child: Image.network(
                            book.image,
                            scale: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:20.0,left:30,right:30),
                    child: Center(
                      child: Container(
                        child: Text(book.title,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 25)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:8,bottom:20),
                    child: Center(
                      child: Container(
                        child: Text(book.authors??"N/A",style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1),fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  Container(        // Size of the container adjusted according to screen
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight:Radius.circular(40),
                          topLeft: Radius.circular(40)
                          ),
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:40,left:30,right:30),
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Listed By',
                                style: TextStyle(color: Color.fromRGBO(82, 93, 92, 1))
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top:15,bottom:10),
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Center(
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Color.fromRGBO(8, 199, 68, 1),
                                        child: book.uploadedBy == null || book.uploadedBy.length==0? Text("NA",style: TextStyle(color: Colors.white,fontSize:15),) : Text(book.uploadedBy[0]+book.uploadedBy[1],style: TextStyle(color: Colors.white,fontSize:15),),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left:15),
                                    child: Container(
                                      child: Text(book.uploadedBy,style: TextStyle(color: Color.fromRGBO(82, 93, 92, 1)))
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:15,bottom:8),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text('About',
                                style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 20,
                                fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 90),
                              child: Text(
                                book.description??"N/A",
                                style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
                                textAlign: TextAlign.justify,
                                ),
                            ),
                            
                          ],
                        ),
                      ),
                    ),  
                ],
              ),
            ),
            Positioned(
              bottom:10,
              left:10,right:10,
              child: GestureDetector(
                onTap: openWhatsapp,
                child: Container(
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
                    padding: const EdgeInsets.only(top:8,bottom:8,left:50,right:50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Exchange',style:TextStyle(color:Colors.white,fontSize: 18,fontWeight: FontWeight.w800)),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(book.price.toString(),style:TextStyle(color:Colors.white,fontSize: 17,fontWeight: FontWeight.w800)),
                                Text('COINS',style:TextStyle(color:Colors.white,fontSize: 10,fontWeight: FontWeight.w800)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left:8),
                              child: Image.asset('assets/dollar_2.png',scale: 3,),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  openWhatsapp() async {
    bool whatsapp = await FlutterLaunch.hasApp(name:"whatsapp");
    if(whatsapp){
      await FlutterLaunch.launchWathsApp(
        phone:book.uploadedPhone,
        message:"Hi there! I checked your listing for '${book.title}' on ComEx app. I want to exchange it for ${book.price}. Let's connect?"
      );
    }
  }
}

class QRScanner extends StatefulWidget {
  final CustomUser user;
  QRScanner({this.user});
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool success,loading,down;
  @override
  void initState() {
    loading = true;
    down = false;
    scan();
    super.initState();
  }

  scan() async {
    ScanResult res = await BarcodeScanner.scan(
      options: ScanOptions(
        restrictFormat: [BarcodeFormat.qr]
      )
    );
    var strings = res.rawContent.split("_");
    print("\n\nID:${strings[0]}");
    print("\n\nPrice:${strings[1]}");
    APIResponse r = await API().exchange(widget.user.firebaseId,strings[0]);
    if(r.code==0){
      print(r.message);
      setState(() {
        success = true;
        loading = false;
      });
    }else{
      print(r.message);
      setState(() {
        success = false;
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            child: Center(
                child: loading ?
                Center(child: Container(width:50,height:50,child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(3, 163, 99, 1)),)))
                    : success ?
                Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top:0.3*MediaQuery.of(context).size.height),
                          child: Text("Exchange Successful!",style:TextStyle(fontSize:20)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top:50),
                            child:Container(
                                width:40,height:40,
                                decoration: BoxDecoration(
                                    color:Colors.green,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Center(child:Icon(Icons.done,size:30,color:Colors.white))
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top:100),
                            child:Text("Happy Reading!",style:TextStyle(color:Color.fromRGBO(69,69,69,0.69)))
                        ),
                        Padding(
                            padding: EdgeInsets.only(top:0.2*MediaQuery.of(context).size.height),
                            child: GestureDetector(
                                onTapDown: (details){
                                  setState(() {
                                    down = true;
                                  });
                                },
                                onTapUp: (details){
                                  setState(() {
                                    down = false;
                                  });
                                },
                                onTap:()=>Navigator.of(context).pop(),
                                child: Container(
                                    height:55,width:140,
                                    decoration: BoxDecoration(
                                        border: Border.all(color:Color.fromRGBO(8, 199, 68, 1)),
                                        borderRadius: BorderRadius.circular(70),
                                        color: down ? Color.fromRGBO(8, 199, 68, 1) : Colors.white
                                    ),
                                    child: Center(
                                        child: Text("Back to Home",style:TextStyle(color:!down ? Color.fromRGBO(8, 199, 68, 1) : Colors.white))
                                    )
                                )
                            )
                        )
                      ],
                    )
                )
                    :Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top:0.3*MediaQuery.of(context).size.height),
                          child: Text("Exchange Failed!",style:TextStyle(fontSize:20)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top:50),
                            child:Container(
                                width:40,height:40,
                                decoration: BoxDecoration(
                                    color:Colors.red,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Center(child:Icon(Icons.close,size:30,color:Colors.white))
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top:150),
                            child:Text("Please try again or contact us.",style:TextStyle(color:Color.fromRGBO(69,69,69,0.69)))
                        ),
                        Padding(
                            padding: EdgeInsets.only(top:0.2*MediaQuery.of(context).size.height),
                            child: GestureDetector(
                                onTapDown: (details){
                                  setState(() {
                                    down = true;
                                  });
                                },
                                onTapUp: (details){
                                  setState(() {
                                    down = false;
                                  });
                                },
                                onTap:()=>Navigator.of(context).pop(),
                                child: Container(
                                    height:55,width:140,
                                    decoration: BoxDecoration(
                                        border: Border.all(color:Colors.red),
                                        borderRadius: BorderRadius.circular(70),
                                        color: down ? Colors.red : Colors.white
                                    ),
                                    child: Center(
                                        child: Text("Back to Home",style:TextStyle(color:!down ? Colors.red : Colors.white))
                                    )
                                )
                            )
                        )
                      ],
                    )
                )
            )
        ),
      )
    );
  }
}


