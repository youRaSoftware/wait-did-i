/// Helpers for classifying an image source string (asset, file, network, svg).
extension StringImageExtensions on String {
  /// Remote image referenced by an http(s) URL.
  bool isNetworkImage() => startsWith('http://') || startsWith('https://');

  /// Absolute path to a file on the device (e.g. a captured photo).
  bool isFilePath() => startsWith('/') || startsWith('file://');

  /// Vector asset rendered with flutter_svg.
  bool isSvg() => toLowerCase().endsWith('.svg');
}
