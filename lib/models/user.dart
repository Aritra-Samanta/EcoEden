import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:ecoeden/services/webservice.dart';
import 'package:ecoeden/screens/home_page.dart';


class User{
  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String mobile;
  final String password;
  final int score;
  final int id;
  final int collections;
  final int posts;
  final int verifications;
  User({this.firstName,this.lastName,this.email,this.userName,this.id,this.mobile,this.password,this.score,this.collections,this.posts,this.verifications});

  factory User.initial(){

    return new User(
      firstName: "" ,
      lastName: "",
      userName: "",
      email: "",
      mobile: "",
      password: "",
      id: 0,
      score: 0,
      collections: 0,
      posts: 0,
      verifications: 0,
    );
  }


  User copyWith({ String firstName, String lastName , String userName , String email, String mobile , String password ,
    int id, int score, int collections, int posts, int verifications}) {
    return new User(
        firstName: firstName ?? this.firstName ,
        lastName : lastName ?? this.lastName ,
        userName : userName ?? this.userName ,
        email :email ?? this.email ,
        mobile :  mobile ?? this.mobile ,
        password : password ?? this.password ,
        id : id ?? this.id,
        score: score ?? this.score,
        collections: collections ?? this.collections,
        posts: posts  ?? this.posts,
        verifications: verifications ?? this.verifications
    );
  }




  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      userName: json['username'],
      email: json['email'],
      score: json['score'],
      mobile: json['mobile'],
      collections: json['collections'],
      posts: json['posts'],
      verifications: json['verifications'],
    );
  }
  Map toMap() {
    var map = new Map<String, dynamic>();
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['username'] = userName;
    map['email'] = email;
    // map['id'] = id;
    map['mobile'] = mobile;
    map['password'] = password;
//    map['score'] = score;
    return map;
  }

  static Resource<List<User>> get all {

    return Resource(
        url: HomePageState.nextPage,
        parse: (response) {
          final result = json.decode(response.body);
          HomePageState.nextPage = result['next'];
          List list = result['results'];
          return list.map((model) => User.fromJson(model)).toList();
        }
    );

  }
}