import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:wvems_protocols/controllers/controllers.dart';
import 'package:wvems_protocols/ui/strings.dart';
import 'package:wvems_protocols/ui/views/nav_dialogs/dialogs.dart';

class HomeBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MessagingController messagingController = Get.find();

    return BottomAppBar(
//      Ekey 7/14 - the pdf doesn't render under the nav bar, so the notch is just blank (looks a little funny)
//      ...so lets just remove the notch
//      shape: const CircularNotchedRectangle(),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
//              Ekey 7/14 - minor tweaks (circle size, position, stack order)
                alignment: const Alignment(0.5, -.5),
                //alignment: const Alignment(0.6, -.7),
                children: <Widget>[
                  _Button(
                    label: S.NAV_MESSAGES,
                    icon: messagingController.hasNewMessage()
                        ? Mdi.emailOpen
                        : Mdi.email,
                    onPressed: () => displayMessagesDialog(context),
                  ),
                  Obx( () => Icon(
                      Icons.circle_rounded,
//                    Ekey 7/14 - made the circle a little bigger to see it better
                      size: 14.0,
//                    Ekey 7/14 - this should be the color assoicated with the year
                      color: Theme.of(context).colorScheme.primary
//                        .primaryColor   //not this color

                          // withAlpha used for Obx, so stream will always be called
                          // if empty, opacity is 0%, else 100%
                          .withAlpha(
                              messagingController.hasNewMessage() ? 255 : 0),
                    ),
                  ),
                ],
              ),
              _Button(
                label: S.NAV_SHARE,
                icon: Mdi.shareVariant,
                onPressed: () => displayShareDialog(context),
              ),
              _Button(
                label: S.NAV_SETTINGS,
                icon: Mdi.cog,
                onPressed: () => displaySettingsDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button(
      {Key? key, required this.icon, required this.label, this.onPressed})
      : super(key: key);

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 30.0),
      ),
    );
  }
}
