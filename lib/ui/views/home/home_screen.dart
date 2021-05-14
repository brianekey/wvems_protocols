import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:wvems_protocols/ui/views/home/fab/home_fab.dart';
import 'package:wvems_protocols/ui/views/home/header/home_screen_header.dart';
import 'package:wvems_protocols/ui/views/nav_drawer/nav_drawer.dart';

import 'body/home_screen_body.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          appBar: AppBar(flexibleSpace: HomeScreenHeader()),
          resizeToAvoidBottomInset: false,
          drawer: NavDrawer(),
          key: _.homeScaffoldKey,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: HomeScreenBody(),
                ),
              ],
            ),
          ),
          floatingActionButton: HomeFab(),
        );
      },
    );
  }
}
