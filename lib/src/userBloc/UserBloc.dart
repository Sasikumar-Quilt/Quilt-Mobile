
import 'package:bloc/bloc.dart';

import '../api/ApiHelper.dart';
import '../api/NetworkApiService.dart';


enum UserEvent { fetchUser }
abstract class UserState {  }
class UserStateInitial extends UserState {}
class UserStateLoading extends UserState {}
class UserStateSuccess extends UserState {
  final ApiResponse userData;
  UserStateSuccess(this.userData);
}
class UserStateFailure extends UserState {}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(super.initialState);
  ApiHelper apiHelper=ApiHelper();
  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event == UserEvent.fetchUser) {
      yield UserStateLoading();
      try {
        final userData = await apiHelper.mobileNumberLoginApi("");
        yield UserStateSuccess(userData);
      } catch (e) {
        yield UserStateFailure();
      }
    }
  }
}
