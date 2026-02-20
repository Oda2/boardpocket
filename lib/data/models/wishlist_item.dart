class WishlistItem {
  final String id;
  final String title;
  final String? imagePath;
  final String? imageUrl;
  final String? price;
  final String? purchaseUrl;
  final String players;
  final String time;
  final String? tag;
  final String? category;
  final DateTime createdAt;

  WishlistItem({
    required this.id,
    required this.title,
    this.imagePath,
    this.imageUrl,
    this.price,
    this.purchaseUrl,
    this.players = '2-4',
    this.time = '60m',
    this.tag,
    this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image_path': imagePath,
      'image_url': imageUrl,
      'price': price,
      'purchase_url': purchaseUrl,
      'players': players,
      'time': time,
      'tag': tag,
      'category': category,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] as String,
      title: map['title'] as String,
      imagePath: map['image_path'] as String?,
      imageUrl: map['image_url'] as String?,
      price: map['price'] as String?,
      purchaseUrl: map['purchase_url'] as String?,
      players: map['players'] as String? ?? '2-4',
      time: map['time'] as String? ?? '60m',
      tag: map['tag'] as String?,
      category: map['category'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  WishlistItem copyWith({
    String? id,
    String? title,
    String? imagePath,
    String? imageUrl,
    String? price,
    String? purchaseUrl,
    String? players,
    String? time,
    String? tag,
    String? category,
    DateTime? createdAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      purchaseUrl: purchaseUrl ?? this.purchaseUrl,
      players: players ?? this.players,
      time: time ?? this.time,
      tag: tag ?? this.tag,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
