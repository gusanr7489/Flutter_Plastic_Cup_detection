import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Count_Detected_Cup with ChangeNotifier{
  int _count = 0 ;
  bool _returnCup = false ;
  bool _ydegree = false ;

  int get count => _count ;
  bool get returnCup => _returnCup ;
  bool get ydegree => _ydegree ;

  void checked() {
    _ydegree = true ;
    notifyListeners();
  }

  void nextStep() {
    _returnCup = true ;
    notifyListeners();
  }

  void add() {
    _count++;
    notifyListeners();
  }

  void clear() {
    _count = 0 ;
    _returnCup = false ;
    notifyListeners();
  }
}