

class Media {
  int? id;
  String? mediaType; 
  String? mediaUrl;
  String? date;
  String? time;

mediaMap(){
var mapping = Map<String,dynamic>();
mapping['id']= id ;
mapping ['mediaType'] = mediaType;
mapping ['mediaUrl'] = mediaUrl;
mapping ['date'] = date;
mapping ['time'] = time;
return mapping;

  } 
}
