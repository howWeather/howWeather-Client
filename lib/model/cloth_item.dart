class ClothItem {
  final int clothType;
  final int color;
  final int thickness;
  final int clothId;

  ClothItem({
    required this.clothType,
    required this.color,
    required this.thickness,
    required this.clothId,
  });
}

class ClothGroup {
  final int clothType;
  final List<ClothItem> items;

  ClothGroup({
    required this.clothType,
    required this.items,
  });
}

class CategoryCloth {
  final String category;
  final List<ClothGroup> clothList;

  CategoryCloth({
    required this.category,
    required this.clothList,
  });
}
