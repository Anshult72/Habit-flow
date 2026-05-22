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

  UserModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? name,
    String? avatarUrl,
    String? city,
    String? state,
    int? xp,
    int? level,
    int? streakShields,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      state: state ?? this.state,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakShields: streakShields ?? this.streakShields,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'email': email,
        'name': name,
        'avatarUrl': avatarUrl,
        'city': city,
        'state': state,
        'xp': xp,
        'level': level,
        'streakShields': streakShields,
      };
}
