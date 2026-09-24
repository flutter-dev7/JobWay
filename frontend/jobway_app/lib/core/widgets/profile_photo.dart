// core/widgets/profile_photo.dart — заменить целиком
import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  final String? photoUrl;
  final String fallbackText;
  final double size;
  final VoidCallback? onEdit;
  final bool isUploading;

  const ProfilePhoto({
    super.key,
    required this.photoUrl,
    required this.fallbackText,
    this.size = 88,
    this.onEdit,
    this.isUploading = false,
  });

  bool get _hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _hasPhoto ? const Color(0xFFDCE5FF) : const Color(0xFFBFD0FF),
                  width: _hasPhoto ? 3 : 2,
                ),
                image: _hasPhoto ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover) : null,
              ),
              child: !_hasPhoto
                  ? Center(
                      child: Text(fallbackText,
                          style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.w700, color: const Color(0xFF3157D5))),
                    )
                  : null,
            ),
            if (onEdit != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: isUploading ? null : onEdit,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3157D5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: isUploading
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(_hasPhoto ? Icons.camera_alt_rounded : Icons.add_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        if (onEdit != null && !_hasPhoto) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isUploading ? null : onEdit,
            child: const Text('Добавить фото', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3157D5))),
          ),
        ],
      ],
    );
  }
}