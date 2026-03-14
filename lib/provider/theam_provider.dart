import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> setTheme(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("theme", value);

    if (value == "dark") {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    log("theam stored successfully");
    notifyListeners();
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String theme = prefs.getString("theme") ?? "light";

    if (theme == "dark") {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    log(theme);
    log("theam loaded successfully");
    notifyListeners();
  }
}
