import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttermoji/fluttermojiFunctions.dart';
import 'package:releaf/utils/conversions.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.avatarType,
    required this.avatarImage,
    this.radius = 55,
  });

  // Data to show correctly the image
  final String avatarType;
  final String avatarImage;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // Type is image, return circular avatar with base64 encoding
    if (avatarType == 'Image') {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(Conversions.baseToImage(avatarImage)),
      );
    }

    // Type is avatar, save locally the Fluttermoji and return the widget
    if (avatarType == 'Avatar') {
      String svgImage = FluttermojiFunctions().decodeFluttermojifromString(
        avatarImage,
      );
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: radius,
        child: ClipOval(
          child: SvgPicture.string(
            svgImage,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // If something went wrong, show default image
    return CircleAvatar(
      radius: radius,
      backgroundImage: MemoryImage(
        Conversions.baseToImage(Conversions.getDefaultAvatarBase()),
      ),
    );
  }
}
