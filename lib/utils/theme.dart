import 'package:flutter/material.dart';
import 'package:flyvanexpress/utils/style.dart';


import 'colors.dart';

ThemeData appTheme = ThemeData(
  primarySwatch: Colors.purple,
  brightness: Brightness.light,
  secondaryHeaderColor: secondaryColor,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: scaffoldBackgroundColor,
  disabledColor: disableColor,
  hintColor: hintColor,
  primaryColorLight: primaryColor,
  fontFamily: 'DMSans',
  cardColor: hintColor,

  dividerColor: dividedColor,

  canvasColor: Colors.white,
  focusColor: Colors.white,
  hoverColor: Colors.white,
  pageTransitionsTheme: PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
  }),
  buttonTheme: ButtonThemeData(),
  listTileTheme: ListTileThemeData(
    dense: true, // Reduces overall spacing
    contentPadding: EdgeInsets.zero, // Adjust padding globally
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.resolveWith(
          (states) => EdgeInsets.symmetric(horizontal: 13, vertical: 3)),
      foregroundColor:
          WidgetStateProperty.resolveWith((states) => textColor(states)),
      textStyle: WidgetStateProperty.resolveWith(outlinedButtonTextStyle),
      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
      shape: WidgetStateProperty.resolveWith(outlinedBorder),
      elevation: WidgetStateProperty.resolveWith(elevation),
      side: WidgetStateProperty.resolveWith((states) => borderColor(states)),
    ),
  ),

  // outlinedButtonTheme: ,
  textTheme: TextTheme(
    titleLarge: boldText,
    //16
    titleMedium: boldText.copyWith(fontSize: 14),
    titleSmall: boldText.copyWith(
      fontSize: 14,
    ),

    bodyMedium: regularText,
    //14
    bodyLarge: regularText.copyWith(
      fontSize: 16,
    ),
    bodySmall: regularText.copyWith(fontSize: 12),

    labelLarge: mediumText.copyWith(fontSize: 14),
    labelMedium: mediumText.copyWith(
      fontSize: 12,
    ),
    labelSmall: mediumText.copyWith(
      fontSize: 11,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style:
    ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey;
            }
            return primaryColor; // Defer to the widget's default.
          }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.white;
            }
            return Colors.white; // Defer to the widget's default.
          }),
    ),
    // ButtonStyle(
    //     shadowColor: MaterialStateProperty.resolveWith(shadowColor),
    //     padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.zero),
    //     elevation: MaterialStateProperty.resolveWith(elevation),
    //     // foregroundColor: MaterialStateProperty.resolveWith(backgroundColor),
    //     backgroundColor: MaterialStateProperty.resolveWith(backgroundColor),
    //     textStyle: MaterialStateProperty.resolveWith(textStyle)),
  ),
);

// ButtonThemeData buttonThemeData = ButtonThemeData(
//     elevation: MaterialStateProperty.resolveWith(elevation),
//     buttonColor: MaterialStateProperty.resolveWith(backgroundColor),
//     textStyle: MaterialStateProperty.resolveWith(textStyle))
// )

const Set<WidgetState> states = <WidgetState>{
  WidgetState.pressed,
  WidgetState.hovered,
  WidgetState.selected
};

OutlinedBorder? outlinedBorder(state) {
  if (state == WidgetState.disabled) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
  } else {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
  }
}

double? elevation(state) {
  if (state == WidgetState.disabled) {
    return 0.0;
  }

  if (states.contains(state)) {
    return 0.0;
  }
  return null;
}

Color? backgroundColor(Set<WidgetState> state) {
  if (state.contains(WidgetState.disabled)) {
    return disableColor;
  }
  return primaryColor;
}

TextStyle? textStyle(Set<WidgetState> state) {
  if (state.contains(WidgetState.disabled)) {
    return boldText.copyWith(
      color: Colors.white,
    );
  }
  //print("Text: $state");
  return boldText.copyWith(
    color: Colors.white,
  );
}

TextStyle? textButtonTextStyle(Set<WidgetState> state) {
  print("Text: $state");
  return mediumText.copyWith(color: Colors.white, fontSize: 11);
}

TextStyle? outlinedButtonTextStyle(Set<WidgetState> state) {
  if (state.contains(WidgetState.disabled)) {
    return mediumText.copyWith(color: disableColor, fontSize: 11);
  } else {
    return mediumText.copyWith(color: primaryColor, fontSize: 11);
  }
}

Color? shadowColor(Set<WidgetState> state) {
  return Colors.transparent;
}

Color? textColor(Set<WidgetState> state) {
  if (state.contains(WidgetState.disabled)) {
    return disableColor;
  } else {
    return primaryColor;
  }
}

BorderSide? borderColor(Set<WidgetState> state) {
  if (state.contains(WidgetState.disabled)) {
    return BorderSide(color: disableColor);
  } else {
    return BorderSide(color: primaryColor);
  }
}
