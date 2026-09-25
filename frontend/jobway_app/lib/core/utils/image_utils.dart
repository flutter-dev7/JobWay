import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<File> ensureCompatibleFormat(File file) async {
    final extension = file.path.split('.').last.toLowerCase();
    if (extension != 'heic' && extension != 'heif') return file;

    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      format: CompressFormat.jpeg,
      quality: 90,
    );

    return result != null ? File(result.path) : file;
  }
}