import 'dart:ui';

Color rgb(int r, int g, int b) {
  return Color.fromRGBO(r, g, b, 1);
}

Color rgba(int r, int g, int b, double a) {
  return Color.fromRGBO(r, g, b, a);
}

Color primaryColor = rgb(22, 22, 29);
Color primaryColorDark = rgb(0, 131, 143);

Color secondaryColor = rgb(2, 115, 63);
Color secondaryColorDark = rgb(75, 0, 98);

Color fontColor = rgb(26, 26, 26);
Color fontColorDark = rgb(255, 255, 255);

Color backgroundColor = rgb(246, 246, 246);
Color backgroundColorDark = rgb(26, 26, 26);

Color greyTextColor = rgb(183, 183, 183);

Color successColor = rgb(14, 255, 22);
Color errorColor = rgb(255, 14, 14);

Color cardColor = rgb(255, 255, 255);
Color cardColorDark = rgb(20, 20, 20);

Color navColor = rgb(255, 255, 255);
Color navColorDark = rgb(0, 0, 0);
