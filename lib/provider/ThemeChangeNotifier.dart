import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThemeChangeNotifier extends ChangeNotifier{
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  void setTheme(themeMde){
    _themeMode = themeMde;
    notifyListeners();
  }
}
