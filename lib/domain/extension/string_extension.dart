extension FileRelated on String {

  String getFileExtension() {
    final fileName = this;

    if (!fileName.contains('.')) return '';
    return '.${fileName.split('.').last}';
  }

  String getFileName() {
    final filePath = this;

    if (!filePath.contains('/')) return '';
    return filePath.split('/').last;
  }

}


extension BulletString on String {

  List<String> toBulletStringList({String separator = '*'}) {

    if (!contains(separator)) return [this];

    final items =
    split(separator)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return items;
  }

}

extension SafeStringForFileNameEtc on String {

  String toSafeJobNameForFileName() {
    String jobName = toLowerCase();

    if (jobName.contains('/')) {
     jobName.replaceAll('/', '');
    }

    if (jobName.contains(' ')) {
      jobName.replaceAll(' ', '_');
    }

    return jobName;
  }

}