import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupState {

  final String childName;
  final String parentMobile;
  final String gender;
  final int age;
  final int classLevel;

  const SignupState({

    this.childName = '',
    this.parentMobile = '',
    this.gender = '',
    this.age = 0,
    this.classLevel = 0,

  });

  SignupState copyWith({

    String? childName,
    String? parentMobile,
    String? gender,
    int? age,
    int? classLevel,

  }) {

    return SignupState(

      childName:
          childName ?? this.childName,

      parentMobile:
          parentMobile ??
          this.parentMobile,

      gender:
          gender ?? this.gender,

      age:
          age ?? this.age,

      classLevel:
          classLevel ??
          this.classLevel,

    );
  }
}


class SignupNotifier extends Notifier<SignupState> {

  @override
  SignupState build() {

    return const SignupState();

  }


  void updateChildName(String value) {

    state =
        state.copyWith(
      childName: value,
    );

  }


  void updateParentMobile(String value) {

    state =
        state.copyWith(
      parentMobile: value,
    );

  }


  void updateGender(String value) {

    state =
        state.copyWith(
      gender: value,
    );

  }


  void updateAge(int value) {

    state =
        state.copyWith(
      age: value,
    );

  }


  void updateClassLevel(int value) {

    state =
        state.copyWith(
      classLevel: value,
    );

  }

}


final signupProvider =
    NotifierProvider<
        SignupNotifier,
        SignupState>(

  SignupNotifier.new,

);