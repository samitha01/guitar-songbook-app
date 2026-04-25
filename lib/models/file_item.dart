class FileItem {
  String id;
  String name;
  bool isFolder;
  String content;
  List<FileItem> subItems;
  double scrollSpeed;
  String songKey;

  FileItem({
    String? id,
    required this.name,
    required this.isFolder,
    this.content = "",
    List<FileItem>? subItems,
    this.scrollSpeed = 1.0,
    this.songKey = "C",
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       subItems = subItems ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isFolder': isFolder,
      'content': content,
      'subItems': subItems.map((item) => item.toJson()).toList(),
      'scrollSpeed': scrollSpeed,
      'songKey': songKey,
    };
  }

  factory FileItem.fromJson(Map<String, dynamic> json) {
    var list = json['subItems'] as List? ?? [];
    List<FileItem> subItemsList = list
        .map((i) => FileItem.fromJson(i))
        .toList();

    return FileItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'],
      isFolder: json['isFolder'],
      content: json['content'] ?? "",
      scrollSpeed: (json['scrollSpeed'] ?? 1.0).toDouble(),
      songKey: json['songKey'] ?? "C",
      subItems: subItemsList,
    );
  }
}
