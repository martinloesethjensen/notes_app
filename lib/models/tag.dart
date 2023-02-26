import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  late String name;

  int colorValue = (Random().nextDouble() * 0xFFFFFF).toInt();

  @ignore
  Color get color => Color(colorValue).withOpacity(.5);
}
