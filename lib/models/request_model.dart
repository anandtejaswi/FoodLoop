// ============================================================
// models/request_model.dart  –  Food Request Data Model
// ============================================================

class RequestModel {
  final String id;
  final String foodId;
  final String foodTitle;
  final String? foodPhotoUrl;
  final String giverId;
  final String giverName;
  final String? giverPhone;
  final String takerId;
  final String takerName;
  final String? takerAvatar;
  final String status;     // 'pending' | 'accepted' | 'rejected' | 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RequestModel({
    required this.id,
    required this.foodId,
    required this.foodTitle,
    this.foodPhotoUrl,
    required this.giverId,
    required this.giverName,
    this.giverPhone,
    required this.takerId,
    required this.takerName,
    this.takerAvatar,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  // ─── Status badge colour ─────────────────────────────────────
  static const Map<String, int> statusColors = {
    'pending':   0xFFFFC107,  // Amber
    'accepted':  0xFF2ECC71,  // Green
    'rejected':  0xFFE74C3C,  // Red
    'completed': 0xFF3498DB,  // Blue
  };

  int get statusColor => statusColors[status] ?? 0xFF9E9E9E;

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
    id:           json['id']?.toString() ?? '',
    foodId:       json['food_id']?.toString() ?? '',
    foodTitle:    json['food_title'] as String? ?? '',
    foodPhotoUrl: json['food_photo_url'] as String?,
    giverId:      json['giver_id']?.toString() ?? '',
    giverName:    json['giver_name'] as String? ?? '',
    giverPhone:   json['giver_phone'] as String?,
    takerId:      json['taker_id']?.toString() ?? '',
    takerName:    json['taker_name'] as String? ?? '',
    takerAvatar:  json['taker_avatar'] as String?,
    status:       json['status'] as String? ?? 'pending',
    createdAt:    json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    updatedAt:    json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id':            id,
    'food_id':       foodId,
    'giver_id':      giverId,
    'taker_id':      takerId,
    'status':        status,
    'created_at':    createdAt.toIso8601String(),
  };
}
