import 'dart:convert';
import 'package:ecoeden/services/webservice.dart';
import 'package:ecoeden/screens/feeds_page.dart';

class FeedsArticle {

  final int id;
  final String image;
  final String createdAt;
  final bool trash;
  final String lat;
  final String lng;
  final String description;
  final int upvotes;
  final int downvotes;
  final Map<String,dynamic> user;
  final List<dynamic> activity;

  FeedsArticle({this.id,
    this.image,
    this.createdAt,
    this.trash,
    this.lat,
    this.lng,
    this.description,
    this.downvotes,
    this.upvotes,
    this.user,
    this.activity
  });

  factory FeedsArticle.fromJson(Map<String,dynamic> json) {
    return FeedsArticle(
      id: json['id'],
      image: json['image'],
      createdAt: json['created_at'],
      trash: json['trash'],
      user : json['user'],
      lat : json['lat'],
      lng : json['lng'],
      description : json['description'],
      upvotes:  json['upvotes'],
      downvotes: json['downvotes'],
      activity: json['activity']
    );

  }

  static Resource<List<FeedsArticle>> get all {

    return Resource(
        url: FeedsPageState.nextPage,
        parse: (response) {
          final result = json.decode(response.body);
          FeedsPageState.nextPage = result['next'];
          List list = result['results'];
          return list.map((model) => FeedsArticle.fromJson(model)).toList();
        }
    );

  }

}
