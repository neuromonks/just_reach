import 'dart:ui';


import 'package:flutter/material.dart';

import '../AppTheme.dart';

class ColorUtils{
  static Color getColorFromRating(int rating,CustomAppTheme customAppTheme,ThemeData themeData){
    switch(rating){
      case 0:
      case 1:
        return customAppTheme.colorError;
      case 2:
        return customAppTheme.colorError.withAlpha(220);
      case 3:
        return Color(0xfff9c700);
      case 4:
        return customAppTheme.colorSuccess.withAlpha(220);
      case 5:
        return customAppTheme.colorSuccess;
    }
    return getColorFromRating(5, customAppTheme, themeData);
  }

}