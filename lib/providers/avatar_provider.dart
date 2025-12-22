import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class AvatarProvider extends ChangeNotifier {
  final userService = UserService();
  String avatarImage = '';

  ImageProvider get imageProvider {
    return MemoryImage(Conversions.baseToImage(avatarImage));
  }

  Future<void> loadAvatar() async {
    Map<String, dynamic>? userData = await userService.getUserData();

    if (userData.isEmpty) return;

    avatarImage = userData['avatar'];

    notifyListeners();
  }

  Future<void> uploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    avatarImage = await Conversions.imageToBase(
      File(picked.path),
      minWidth: 100,
    );

    String uid = userService.getUserUID();
    await FirebaseDatabase.instance.ref('users/$uid/avatar').set(avatarImage);

    notifyListeners();
  }

  Future<void> deleteAvatar() async {
    avatarImage = Conversions.getDefaultAvatarBase();

    String uid = userService.getUserUID();
    await FirebaseDatabase.instance.ref('users/$uid/avatar').set('');

    notifyListeners();
  }
}
