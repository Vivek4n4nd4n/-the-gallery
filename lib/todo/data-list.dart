class DataList {
  final String message;
  final String mediaUrl;
  final String image;
  final String id;
  DataList(
      {required this.message,
      required this.mediaUrl,
      required this.image,
      required this.id});

  factory DataList.fromJson(Map<String, dynamic> json) {
    return DataList(
      message: json["show"].toString(),
      id: json['_id'].toString(),
      mediaUrl: json['mediaUrl'].toString(),
      image: json['mediaType'].toString(),
    );
  }
}
