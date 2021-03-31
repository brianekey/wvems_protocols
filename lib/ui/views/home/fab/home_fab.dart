import 'package:flutter/material.dart';
import 'package:wvems_protocols/controllers/commands/commands.dart';

class HomeFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton(
      elevation: 4.0,
      child: const Icon(Icons.arrow_upward_rounded, size: 36.0),
      onPressed: () async => await SetPageCommand().execute());
}
