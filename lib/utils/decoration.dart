import 'package:flutter/material.dart';

DecorationImage logoBgDecorationImage() {
  return DecorationImage(
      opacity: 0.1,
      alignment: Alignment.lerp(Alignment.center, Alignment.bottomCenter, 0.5)??Alignment.center,
      image: AssetImage("assets/images/logo4.png"),
      fit: BoxFit.contain);
}