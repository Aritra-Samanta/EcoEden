import 'dart:convert';
import 'package:ecoeden/services/webservice.dart';
import 'package:ecoeden/screens/feeds_page.dart';

class FeedsArticle {

  final int id;
  final String image;
  final String createdAt;
  final String lat;
  final String lng;
  final String description;
  final Map<String,dynamic> user;
  HasVoted voted;
  HasVerified verified;
  bool is_indoors;

  FeedsArticle({
    this.id,
    this.image,
    this.createdAt,
    this.lat,
    this.lng,
    this.description,
    this.user,
    this.voted,
    this.verified,
    this.is_indoors,
  });

  factory FeedsArticle.fromJson(Map<String,dynamic> json) {
    return FeedsArticle(
      id: json['id'],
      image: json['image'],
      createdAt: json['created_at'],
      user : json['user'],
      lat : json['lat'],
      lng : json['lng'],
      description : json['description'],
      is_indoors: json['is_indoors'],
      voted: HasVoted(json['upvotes'], json['downvotes'], json['activity']),
      verified: HasVerified(json['trash_collection']),
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

class HasVoted {
  bool trashed, disliked;
  int upvotes, downvotes, activityId;
  HasVoted(up, down, act) {
    activityId = act.length != 0 ? act[0]['id'] : -1;
    upvotes = up;
    downvotes = down;
    if (act.length == 0 || act[0]['vote'] == 0) {
      disliked = false;
      trashed = false;
    } else if (act[0]['vote'] > 0) {
      disliked = false;
      trashed = true;
    } else {
      disliked = true;
      trashed = false;
    }
  }
}

class HasVerified {
  bool trashed, disliked, collected;
  int upvotes, downvotes, trashId, activityId;
  HasVerified(trashCollectionObj) {
    if(trashCollectionObj.length == 0) {
      collected = false;
      activityId = -1;
      trashId = -1;
      upvotes = 0;
      downvotes = 0;
      trashed = false;
      disliked = false;
    }
    else {
      collected = true;
      trashId = trashCollectionObj['id'];
      upvotes = trashCollectionObj['upvotes'];
      downvotes = trashCollectionObj['downvotes'];
      var act = trashCollectionObj['activity'];
      activityId = act.length != 0 ? act[0]['id'] : -1;
      if (act.length == 0 || act[0]['vote'] == 0) {
        disliked = false;
        trashed = false;
      } else if (act[0]['vote'] > 0) {
        disliked = false;
        trashed = true;
      } else {
        disliked = true;
        trashed = false;
      }
    }
  }
}
