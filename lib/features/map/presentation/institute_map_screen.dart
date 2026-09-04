import 'package:flutter/material.dart';
import '../../../widgets/map/institute_map.dart';

class InstituteMapScreen extends StatelessWidget {
  const InstituteMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Institute Map')),
      body: const SafeArea(child: InstituteMap()),
    );
  }
}