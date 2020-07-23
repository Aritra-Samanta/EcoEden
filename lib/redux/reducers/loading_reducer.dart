import 'package:ecoeden/redux/actions.dart';
import 'package:redux/redux.dart';

final loadingReducer = combineReducers<bool>([
  TypedReducer< bool , LoadingStartAction > (_loadingStart),
  TypedReducer< bool , LoadingEndAction > (_loadingEnd),
]);

bool _loadingStart (bool prev,LoadingStartAction action){
  return true;
}

bool _loadingEnd (bool prev,LoadingEndAction action){
  return false;
}