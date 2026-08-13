import 'package:flutter/material.dart';
import 'package:get/get.dart';

// TODO: apne project ke actual path ke hisaab se adjust karlein
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientProfilescreensection/clientProfilecontroller.dart';
class ProfileAvatar extends StatelessWidget {
  final double radius;
  final double? iconSize;
  const ProfileAvatar({
    super.key,
    required this.radius,
    this.iconSize,
  });
  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Obx(() {
      final ImageProvider? imageProvider = controller.avatarImageOrNull;

      if (imageProvider != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
        );
      }

      // Koi profile pic set nahi -> grey placeholder + person icon
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        child: Icon(
          Icons.person,
          size: iconSize ?? radius * 1.1,
          color: Colors.grey.shade600,
        ),
      );
    });
  }
}