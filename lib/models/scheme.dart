import 'package:flutter/material.dart';

enum SchemeType { ngo, educational, economicDevelopment, socialEmpowerment }

class Scheme {
  final SchemeType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const Scheme({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
