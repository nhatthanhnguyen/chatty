String identifyFileType(String url) {
  final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
  final fileExtension = url.substring(url.lastIndexOf('.'));

  if (imageExtensions.contains(fileExtension.toLowerCase())) {
    return 'image';
  } else {
    return 'file';
  }
}
