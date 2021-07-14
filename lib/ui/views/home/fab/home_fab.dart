import 'package:flutter/material.dart';
import 'package:wvems_protocols/controllers/commands/commands.dart';

class HomeFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: FloatingActionButton(
          elevation: 4.0,
//        Ekey 7/14 - makes the FAB an arrow pointing up (I like better than house icon)
          child: const Icon(Icons.arrow_upward_rounded, size: 36.0),
          onPressed: () async => await SetPageCommand().execute(),
        ),
      );
}
