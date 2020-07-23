import 'package:ecoeden/redux/app_state.dart';
import 'package:ecoeden/redux/reducers/feed_reducer.dart';
import 'package:ecoeden/redux/reducers/loading_reducer.dart';
import 'package:ecoeden/redux/reducers/navigation_reducers.dart';
import 'package:ecoeden/redux/reducers/user_reducer.dart';
import 'package:ecoeden/redux/actions.dart';
import 'package:redux/redux.dart';

AppState appReducer(AppState state, action) {
  return AppState(
    isLoading: loadingReducer(state.isLoading, action),
    user : userReducer( state.user , action ),
    route: navigationReducer(state.route, action) ,
    feeds : feedReducer( state.feeds , action ),
    lat   : latReducer( state.lat , action),
    lng   : lngReducer( state.lng , action),
  );
}

//  String latlngReducer(String state,dynamic action){
//      if(action == LatAction)
//          return action.lat;
//      if(action == LngAction)
//          return action.lng;
//      return state;
//  }
final lngReducer = combineReducers<String>([
  TypedReducer< String ,  LngAction > (_lng),
]);


final latReducer = combineReducers<String>([
  TypedReducer< String ,  LatAction > (_lat),
]);

String _lat (String prev,LatAction action){

  return action.lat;
}

String _lng (String prev,LngAction action){
  return action.lng;
}

