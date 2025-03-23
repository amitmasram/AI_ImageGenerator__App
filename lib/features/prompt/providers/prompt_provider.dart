import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import '../repos/prompt_repo.dart';

enum PromptState {
  initial,
  loading,
  success,
  error,
}

class PromptProvider with ChangeNotifier {
  PromptState _state = PromptState.initial;
  Uint8List? _imageData;
  String _errorMessage = '';
  bool _isSaving = false;

  PromptState get state => _state;
  Uint8List? get imageData => _imageData;
  String get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  Future<void> initialize() async {
    try {
      _state = PromptState.initial;
      notifyListeners();
    } catch (e) {
      _state = PromptState.error;
      _errorMessage = 'Failed to initialize: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> generateImage(String prompt) async {
    if (prompt.isEmpty) return;

    try {
      _state = PromptState.loading;
      notifyListeners();

      final imageBytes = await PromptRepo.generateImage(prompt);

      if (imageBytes != null) {
        _imageData = imageBytes;
        _state = PromptState.success;
      } else {
        _state = PromptState.error;
        _errorMessage = 'Failed to generate image';
      }
    } catch (e) {
      _state = PromptState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

Future<bool> saveImageToGallery() async {
  if (_imageData == null) return false;

  try {
    _isSaving = true;
    notifyListeners();

    // Debug the image data
    print("Image data length: ${_imageData!.length}");

    // For Android 10+ (API level 29+), we need to use MediaStore API
    // For Android 13+ (API level 33+), we need more granular permissions

    // Try multiple permission approaches
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.photos,
      Permission.mediaLibrary,
    ].request();

    print("Permission statuses: $statuses");

    // Check if any permission is granted
    bool hasPermission = statuses.values.any((status) => status.isGranted);

    if (hasPermission) {
      try {
        // Try with the first package
        await FlutterImageGallerySaver.saveImage(_imageData!);
        print("Image saved successfully");

        _isSaving = false;
        notifyListeners();
        return true;
      } catch (e) {
        print("Error with primary save method: $e");
        throw e;  // Re-throw to be caught by outer catch
      }
    } else {
      print("All permissions denied");
      _isSaving = false;
      notifyListeners();
      return false;
    }
  } catch (e) {
    print("Error saving image: $e");
    _isSaving = false;
    _errorMessage = 'Failed to save image: ${e.toString()}';
    notifyListeners();
    return false;
  }
}
}
