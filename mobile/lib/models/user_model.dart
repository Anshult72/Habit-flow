class UserModel {
  final String id;
  final String userId;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final String? city;
  final String? state;
  final int xp;
  final int level;
  final int streakShields;

  UserModel({
    required this.id,
    required this.userId,
    this.email,
    this.name,
    this.avatarUrl,
    this.city,
    this.state,
    required this.xp,
    required this.level,
    required this.streakShields,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      city: json['city'],
      state: json['state'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      streakShields: json['streakShields'] ?? 0,
    );
  }
}
