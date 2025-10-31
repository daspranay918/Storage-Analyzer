class FileCategoryModel {
  final String name;
  final int count;
  final int size; 

  FileCategoryModel({
    required this.name,
    required this.count,
    required this.size,
  });

  String get formattedSize {
    if (size <= 0) return "0.00 KB";
    double kb = size / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(2)} KB";
    double mb = kb / 1024;
    if (mb < 1024) return "${mb.toStringAsFixed(2)} MB";
    double gb = mb / 1024;
    return "${gb.toStringAsFixed(2)} GB";
  }
}
