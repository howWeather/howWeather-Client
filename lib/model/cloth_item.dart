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

  ClothItem copyWith({
    int? color,
    int? thickness,
  }) {
    return ClothItem(
      clothType: this.clothType,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      clothId: this.clothId,
    );
  }

  factory ClothItem.fromJson(Map<String, dynamic> json) {
    return ClothItem(
      clothType: json['clothType'],
      color: json['color'],
      thickness: json['thickness'],
      clothId: json['clothId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'clothType': clothType,
        'color': color,
        'thickness': thickness,
        'clothId': clothId,
      };
}

class ClothGroup {
  final int clothType;
  final List<ClothItem> items;

  ClothGroup({
    required this.clothType,
    required this.items,
  });

  factory ClothGroup.fromJson(Map<String, dynamic> json) {
    return ClothGroup(
      clothType: json['clothType'],
      items: (json['items'] as List)
          .map((item) => ClothItem.fromJson(item))
          .toList(),
    );
  }
}

class CategoryCloth {
  final String category;
  final List<ClothGroup> clothList;

  CategoryCloth({
    required this.category,
    required this.clothList,
  });

  factory CategoryCloth.fromJson(Map<String, dynamic> json) {
    return CategoryCloth(
      category: json['category'],
      clothList: (json['clothList'] as List)
          .map((item) => ClothGroup.fromJson(item))
          .toList(),
    );
  }
}
