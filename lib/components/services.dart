import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'components.dart';

class LocalStorageService {
  final String _uid;
  LocalStorageService(this._uid);

  Future postTofirstIndex(String key, dynamic value) async {
    try {
      if (!Hive.isBoxOpen("ls-$_uid")) {
        await Hive.openBox("ls-$_uid");
      }
      Box box = Hive.box("ls-$_uid");
      List currentValue = await box.get(key) ?? [];
      currentValue.insert(0, value);
      return await box.put("myLysts", currentValue);
    } catch (e) {
      return AppFailLogs.hiveFail();
    }
  }

  Future editLyst(Lyst lyst) async {
    try {
      if (!Hive.isBoxOpen("ls-$_uid")) {
        await Hive.openBox("ls-$_uid");
      }
      Box box = Hive.box("ls-$_uid");
      List currentMyLysts = await box.get("myLysts");
      int index = currentMyLysts.indexWhere((element) => element["lystId"] == lyst.lystId);
      if (index < 0) throw AppFailLogs.internalError();
      currentMyLysts.replaceRange(index, ++index, [lyst.toJson()]);
      return await box.put("myLysts", currentMyLysts);
    } catch (e) {
      return AppFailLogs.hiveFail();
    }
  }

  Future deleteLyst(String lystId) async {
    try {
      if (!Hive.isBoxOpen("ls-$_uid")) {
        await Hive.openBox("ls-$_uid");
      }
      Box box = Hive.box("ls-$_uid");
      List currentMyLysts = box.get("myLysts");
      currentMyLysts.removeWhere((element) => element["lystId"] == lystId);
      return await box.put("myLysts", currentMyLysts);
    } catch (e) {
      return AppFailLogs.hiveFail();
    }
  }
}

class UserHttpRequest {
  final String _uid;
  String get uid => _uid;
  const UserHttpRequest(String uid) : _uid = uid;
  String get url => "url/$uid";

  registerUser() {}
  postLyst() {}
  getUser() {}

  //mock services --dev env;
  Future mockRegisterSuccess(Map data) async {
    return Future.delayed(const Duration(milliseconds: 1000)).then((value) => {"statusCode": 201});
  }

  Future mockRegisterFailure(Map data) async {
    return Future.delayed(const Duration(milliseconds: 200)).then((value) => {"statusCode": 500});
  }

  Future mockPostLystSuccess(Map data) async {
    return Future.delayed(const Duration(milliseconds: 200))
        .then((value) => {"statusCode": 201, "lystId": "lystId-${math.Random().nextInt(100)}"});
  }

  Future mockDeleteLystSuccess(String lystId) async {
    return Future.delayed(const Duration(milliseconds: 200)).then((value) => {"statusCode": 200});
  }

  Future mockPutLystsSuccess(Lyst lyst) async {
    return Future.delayed(const Duration(milliseconds: 200)).then((value) => {"statusCode": 200});
  }

  Future mockGetUser() async {
    // ignore: unused_local_variable
    String url = "https://address/user=$uid";
    return await Future.delayed(const Duration(milliseconds: 1000))
        .then((value) => {"statusCode": 200, "uid": uid, "name": "the real genish", "myLysts": jsons});
  }
}

// should be Firebase configuration
class AuthService with ChangeNotifier {
  String? _uid;
  String? get uid => _uid;
  set setUid(String? uid) {
    _uid = uid;
    notifyListeners();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  Future<void> handleGoogleSignIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (error) {
    print(error);
  }
}

  void setUidandClose(BuildContext context, String? uid) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 300));
    _uid = uid;
    notifyListeners();
  }
}

class AppFailLogs {
  Map errorMessage;
  AppFailLogs(this.errorMessage);

  static internalError({Object? err}) => AppFailLogs({"info": "inetrnal problam"});
  static hiveFail({Object? err}) => AppFailLogs({"info": "hive have failed"});
  static httpFail({Object? err}) => AppFailLogs({"info": "http request landed a fail"});
  static success() => {"info": "success"};
}
