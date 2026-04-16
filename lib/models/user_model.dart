// ============================================================
// models/user_model.dart  –  User Data Model
// ============================================================

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;          // 'giver' | 'taker'
  final String? avatarUrl;
  final int points;
  final double rating;
  final int impactScore;      // kg of food saved
  final String? googleId;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.points = 0,
    this.rating = 0.0,
    this.impactScore = 0,
    this.googleId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:          json['id']?.toString() ?? '',
    name:        json['name'] as String? ?? 'User',
    email:       json['email'] as String? ?? '',
    role:        json['role'] as String? ?? '',
    avatarUrl:   json['avatar_url'] as String?,
    points:      json['points'] as int? ?? 0,
    rating:      (json['rating'] as num?)?.toDouble() ?? 0.0,
    impactScore: json['impact_score'] as int? ?? 0,
    googleId:    json['google_id'] as String?,
    createdAt:   json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id':           id,
    'name':         name,
    'email':        email,
    'role':         role,
    'avatar_url':   avatarUrl,
    'points':       points,
    'rating':       rating,
    'impact_score': impactScore,
    'google_id':    googleId,
    'created_at':   createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    String? role,
    int? points,
    double? rating,
    int? impactScore,
  }) => UserModel(
    id:          id,
    name:        name ?? this.name,
    email:       email,
    role:        role ?? this.role,
    avatarUrl:   avatarUrl ?? this.avatarUrl,
    points:      points ?? this.points,
    rating:      rating ?? this.rating,
    impactScore: impactScore ?? this.impactScore,
    googleId:    googleId,
    createdAt:   createdAt,
  );
}
