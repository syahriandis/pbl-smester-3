class ImageUrlHelper {
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // Jika sudah full URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Jika path dimulai dengan 'storage/'
    if (imagePath.startsWith('storage/')) {
      return 'http://localhost:8000/$imagePath';
    }
    
    // Jika path dimulai dengan 'api/storage/'
    if (imagePath.startsWith('api/storage/')) {
      return 'http://localhost:8000/$imagePath';
    }
    
    // Jika path relatif biasa
    if (!imagePath.startsWith('/')) {
      return 'http://localhost:8000/storage/$imagePath';
    }
    
    // Default
    return 'http://localhost:8000$imagePath';
  }
}
