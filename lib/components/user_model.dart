import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'components.dart';

class UserModel extends ChangeNotifier {
  String? name;
  String? uid;
  String headUri = "assets/default_male_head.svg";
  late final UserHttpRequest _userHttpRequest;
  Map<String, List<dynamic>> avaialableLystTypes = {
    "coding": [FontAwesomeIcons.laptopCode, null, null],
    "eShopping": [FontAwesomeIcons.shoppingBag, null, null],
    "goals": [FontAwesomeIcons.bullseye, null, null],
    "love": [FontAwesomeIcons.heart, null, null],
    "painting": [FontAwesomeIcons.paintBrush, null, null],
    "research": [FontAwesomeIcons.search, null, null],
    "styling": [FontAwesomeIcons.vestPatches, null, null],
    "yoga": [FontAwesomeIcons.om, null, null],
    "youtubing": [FontAwesomeIcons.video, null, null]
  };
  // ignore: unused_field
  late final LocalStorageService _ls;
  List<Lyst> myLysts;
  AuthService authService;
  List<Lyst> get lysts => myLysts;
  UserModel({required this.authService, this.uid, this.name, this.myLysts = const []}) {
    uid = authService.uid;
    _userHttpRequest = UserHttpRequest(uid ?? "");
    _ls = LocalStorageService(uid ?? "");
    getUser();
  }

  Future addLyst(String title, String? description, String type) async {
    Lyst newLyst = Lyst(title: title, tasks: [], lystId: const Uuid().v4(), type: type);
    lysts.add(newLyst);
    notifyListeners();
  }

  Future deleteLyst(Lyst lyst) async {
    int index = lysts.indexOf(lyst);
    if (index.isNegative) {
      return;
    }
    lysts.removeAt(index);
    notifyListeners();
  }

  Future editLyst(Lyst lyst) async {
    int index = lysts.indexWhere((element) => element.lystId == lyst.lystId);
    if (index.isNegative) {
      return;
    }
    lysts.replaceRange(index, ++index, [lyst]);
    notifyListeners();
  }

  getUser() async {
    var jsonData = await _userHttpRequest.mockGetUser(); // cache control

    if (jsonData["statusCode"] == 200) {
      name = jsonData["name"];
      myLysts = List.generate(jsonData["myLysts"].length, (index) => Lyst.fromJson(jsonData["myLysts"][index]));
    }
    notifyListeners();
  }

  Future syncLystWithResources() async {}

  refresh() => notifyListeners();

  setNameNUid(_name, _uid) {
    name = name;
    uid = _uid;
    //cache control
    notifyListeners();
  }

  Future<void> logOut() async {
    notifyListeners();
  }

  Future register(Map data) async {}

  Future getAvailableLystVersion() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}
