import 'dart:io';
import 'dart:typed_data';

class UserImage {
  final Uint8List? bytes;
  final File? file;

  UserImage.web(this.bytes) : file = null;
  UserImage.mobile(this.file) : bytes = null;

  bool get isWeb => bytes != null;
}
