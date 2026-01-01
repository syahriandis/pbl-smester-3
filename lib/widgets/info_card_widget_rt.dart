import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';

class InfoCardWidgetRT extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InfoCardWidgetRT({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  String _getFullImageUrl(String path) {
    if (path.isEmpty) return '';
    
    // Jika sudah full URL (http/https)
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Jika path dari database (storage/informasi/...)
    // Tambahkan base URL backend
    return 'http://localhost:8000/$path';
  }

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = _getFullImageUrl(imagePath);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: fullImageUrl.isNotEmpty
              ? Image.network(
                  fullImageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Jika gagal load, tampilkan icon placeholder
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}