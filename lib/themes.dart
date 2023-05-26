import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const c1 = Color(0xff1b1a1d);
const c2 = Color(0xffafd3e2);

var tapInDarkColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue,
  brightness: Brightness.dark,
  surface: c1,
  primary: c2,
);
var textStyle = TextStyle(
  color: tapInDarkColorScheme.onSurface,
  fontWeight: FontWeight.w500,
);
var textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);

var buttonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: c2, foregroundColor: c1));

var tapInDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: tapInDarkColorScheme,
  navigationBarTheme: NavigationBarThemeData(
    labelTextStyle: MaterialStateProperty.all(textStyle),
  ),
  canvasColor: c1,
  scaffoldBackgroundColor: c1,
  textTheme: textTheme,
  elevatedButtonTheme: buttonTheme,
  inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
  snackBarTheme: SnackBarThemeData(backgroundColor: c2),
);
