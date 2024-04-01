import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  Future<CloudStorageResult?> uploadImage({
    required File imageToUpload,
    required String title,
  }) async {}
}

class CloudStorageResult {
  final String imageUrl;
  final String imageFileName;

  CloudStorageResult({required this.imageUrl, required this.imageFileName});
}
