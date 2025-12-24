import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class AvatarProvider extends ChangeNotifier {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Default values, the avatar is set to the default avatar and the pick image
  // to false
  String avatarImage = Conversions.getDefaultAvatarBase();
  bool _isPickingImage = false;

  // Returns the avatar as a Widget/Image
  ImageProvider get imageProvider {
    return MemoryImage(Conversions.baseToImage(avatarImage));
  }

  // Initialization function to get if the user avatar
  Future<void> loadAvatar() async {
    Map<String, dynamic>? userData = await _userService.getUserData();

    if (userData.isEmpty) {
      avatarImage = Conversions.getDefaultAvatarBase();

      notifyListeners();
      return;
    }

    avatarImage = userData['avatar'];

    notifyListeners();
  }

  // If the user is not already picking, changes the avatar, and updates the
  // database
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

    String uid = _userService.getUserUID();
    await FirebaseDatabase.instance.ref('users/$uid/avatar').set(avatarImage);

    _isPickingImage = false;

    notifyListeners();
  }

  // Changes the avatar to the default avatar, and updates the database
  Future<void> deleteAvatar() async {
    avatarImage = Conversions.getDefaultAvatarBase();

    String uid = _userService.getUserUID();
    await FirebaseDatabase.instance.ref('users/$uid/avatar').set('');

    notifyListeners();
  }

  // Resets the avatar to the default avatar
  void reset() {
    avatarImage = Conversions.getDefaultAvatarBase();
    notifyListeners();
  }
}
