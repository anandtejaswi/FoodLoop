// ============================================================
// models/food_item_model.dart  –  Food Listing Data Model
// ============================================================

class FoodItemModel {
  final String id;
  final String giverId;
  final String giverName;
  final String? giverAvatar;
  final double giverRating;
  final String title;
  final String category;       // 'meals' | 'produce' | 'bakery' | 'dairy' | 'other'
  final String description;
  final int quantity;
  final String quantityUnit;
  final double lat;
  final double lng;
  final String address;
  final DateTime expiryTime;
  final String? photoUrl;
  final String status;         // 'available' | 'claimed' | 'completed' | 'expired'
  final DateTime createdAt;
  final double? distanceKm;    // Populated on client side

  const FoodItemModel({
    required this.id,
    required this.giverId,
    required this.giverName,
    this.giverAvatar,
    this.giverRating = 0.0,
    required this.title,
    required this.category,
    required this.description,
    required this.quantity,
    this.quantityUnit = 'portions',
    required this.lat,
    required this.lng,
    required this.address,
    required this.expiryTime,
    this.photoUrl,
    this.status = 'available',
    required this.createdAt,
    this.distanceKm,
  });

  // ─── Time remaining helper ───────────────────────────────────
  String get timeRemaining {
    final diff = expiryTime.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours < 1) return '${diff.inMinutes}m left';
    if (diff.inHours < 24) return '${diff.inHours}h left';
    return '${diff.inDays}d left';
  }

  bool get isExpired => expiryTime.isBefore(DateTime.now());

  // ─── Category icon mapping ───────────────────────────────────
  static const Map<String, String> categoryIcons = {
    'meals':   '🍱',
    'produce': '🥦',
    'bakery':  '🍞',
    'dairy':   '🥛',
    'other':   '🍴',
  };

  String get categoryIcon => categoryIcons[category] ?? '🍴';

  factory FoodItemModel.fromJson(Map<String, dynamic> json) => FoodItemModel(
    id:           json['id']?.toString() ?? '',
    giverId:      json['giver_id']?.toString() ?? '',
    giverName:    json['giver_name'] as String? ?? 'Unknown',
    giverAvatar:  json['giver_avatar'] as String?,
    giverRating:  (json['giver_rating'] as num?)?.toDouble() ?? 0.0,
    title:        json['title'] as String? ?? 'Untitled',
    category:     json['category'] as String? ?? 'other',
    description:  json['description'] as String? ?? '',
    quantity:     json['quantity'] as int? ?? 1,
    quantityUnit: json['quantity_unit'] as String? ?? 'portions',
    lat:          ((json['lat'] as num?) ?? 0).toDouble(),
    lng:          ((json['lng'] as num?) ?? 0).toDouble(),
    address:      json['address'] as String? ?? '',
    expiryTime:   json['expiry_time'] != null ? DateTime.parse(json['expiry_time'] as String) : DateTime.now().add(const Duration(days: 1)),
    photoUrl:     json['photo_url'] as String?,
    status:       json['status'] as String? ?? 'available',
    createdAt:    json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    distanceKm:   (json['distance_km'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'giver_id':     giverId,
    'title':        title,
    'category':     category,
    'description':  description,
    'quantity':     quantity,
    'quantity_unit':quantityUnit,
    'lat':          lat,
    'lng':          lng,
    'address':      address,
    'expiry_time':  expiryTime.toIso8601String(),
    'photo_url':    photoUrl,
    'status':       status,
  };
}
