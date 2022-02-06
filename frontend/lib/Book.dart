class BookAPIQuery{
  final String title,description,infoLink,image,authors,id; 
  final int pages;final dynamic rating;
  String etag,uploadedOn,uploadedBy,uploadedPhone;
  bool taken;int price;
  BookAPIQuery({this.id,this.title,this.description,this.image,this.infoLink,this.pages,this.rating,this.authors,this.price,this.uploadedOn,this.etag,this.taken,this.uploadedBy,this.uploadedPhone});

  factory BookAPIQuery.fromJson(Map<String, dynamic> map){
    final jsonList = (map['items'] as List);
    var books =  jsonList.map((jsonBook) => BookAPIQuery(
      title: jsonBook['volumeInfo']['title'],
      authors: (jsonBook['volumeInfo']['authors'] as List).join(', ').replaceAll('Authors', ''),
      image: jsonBook['volumeInfo']['imageLinks']['smallThumbnail'],
      infoLink: jsonBook['volumeInfo']['infoLink'],
      description: jsonBook['volumeInfo']['description'],
      pages: jsonBook['volumeInfo']['pageCount'],
      rating: jsonBook['volumeInfo']['averageRating'],
      etag: jsonBook["etag"]
    ))
    .toList();
    return books[0];
  }

  void show(){
    print("Title: "+this.title);
    print("Authors: " + this.authors);
    print("Pages: "+this.pages.toString());
    print("Rating: "+this.rating.toString());
  }
}

