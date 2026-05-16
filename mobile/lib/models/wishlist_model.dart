class WishlistModel {
  final String id;
  final String title;
  final double price;
  final double targetPrice;
  final double currentSavings;
  final String? category;
  final String? link;
  final String? image;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  WishlistModel({
    required this.id,
    required this.title,
    required this.price,
    required this.targetPrice,
    required this.currentSavings,
    this.category,
    this.link,
    this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress => targetPrice > 0 ? (currentSavings / targetPrice * 100).clamp(0, 100) : 0;

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'],
      title: json['title'],
      price: (json['price'] ?? 0).toDouble(),
      targetPrice: (json['targetPrice'] ?? 0).toDouble(),
      currentSavings: (json['currentSavings'] ?? 0).toDouble(),
      category: json['category'],
      link: json['link'],
      image: json['image'],
      status: json['status'] ?? 'Active',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'targetPrice': targetPrice,
      'currentSavings': currentSavings,
      'category': category,
      'link': link,
      'image': image,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WishlistModel copyWith({
    String? id,
    String? title,
    double? price,
    double? targetPrice,
    double? currentSavings,
    String? category,
    String? link,
    String? image,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      targetPrice: targetPrice ?? this.targetPrice,
      currentSavings: currentSavings ?? this.currentSavings,
      category: category ?? this.category,
      link: link ?? this.link,
      image: image ?? this.image,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
