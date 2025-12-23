import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class AvatarProvider extends ChangeNotifier {
  final userService = UserService();
  String avatarImage = Conversions.getDefaultAvatarBase();
  bool _isPickingImage = false;

  ImageProvider get imageProvider {
    return MemoryImage(Conversions.baseToImage(avatarImage));
  }

  Future<void> loadAvatar() async {
    Map<String, dynamic>? userData = await userService.getUserData();

    if (userData.isEmpty) {
      avatarImage = Conversions.getDefaultAvatarBase();

      notifyListeners();
      return;
    }

    avatarImage = userData['avatar'];

    notifyListeners();
  }

  Future<void> uploadAvatar() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) {
      _isPickingImage = false;
      return;
    }

    avatarImage = await Conversions.imageToBase(
      File(picked.path),
      minWidth: 100,
    );

    String uid = userService.getUserUID();
    await FirebaseDatabase.instance.ref('users/$uid/avatar').set(avatarImage);

    _isPickingImage = false;

    notifyListeners();
  }

  Future<void> deleteAvatar() async {
    avatarImage = Conversions.getDefaultAvatarBase();

    String uid = userService.getUserUID();
    await FirebaseDatabase.instance.ref('users/$uid/avatar').set('');

    notifyListeners();
  }

  void reset() {
    avatarImage = Conversions.getDefaultAvatarBase();
    notifyListeners();
  }
}
