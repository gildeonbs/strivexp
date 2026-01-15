class CategoryModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String icon;
  final bool isSelected;

  CategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.isSelected,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  // Método copyWith para facilitar a mutabilidade do estado na UI
  CategoryModel copyWith({bool? isSelected}) {
    return CategoryModel(
      id: id,
      code: code,
      name: name,
      description: description,
      icon: icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}


