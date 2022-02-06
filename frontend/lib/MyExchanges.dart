import 'dart:async';
import 'package:comex/API.dart';
import 'package:comex/Book.dart';
import 'package:comex/CustomUser.dart';
import 'package:flutter/material.dart';

class MyExchanges extends StatefulWidget {
  final CustomUser user;
  MyExchanges({this.user});
  @override
  _MyExchangesState createState() => _MyExchangesState();
}

class _MyExchangesState extends State<MyExchanges> {
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
                      child: Text("My Exchanges",style:TextStyle(fontSize: 20))
                    ),
                  ],
                ), 
                loading ? 
                Container(height:MediaQuery.of(context).size.height,width:MediaQuery.of(context).size.width,child: Center(child: Container(width:50,height:50,child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(3, 163, 99, 1)),))))
                : books.length==0 ?   
                  Container(
                    width:MediaQuery.of(context).size.width,
                    height:MediaQuery.of(context).size.height,
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
                        return 
                        books[index].taken ?
                        Padding(
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
                        ) : Container();
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

  getBooks() {
    API().getExchanges(widget.user.firebaseId).then((res){
      if(res.code==0){
        setState(() {
          books = res.book;
        });
      }
    });    
  }
}