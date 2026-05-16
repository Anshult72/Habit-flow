class LeaderboardUserModel {
  final String id;
  final String? name;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int rank;

  LeaderboardUserModel({
    required this.id,
    this.name,
    this.avatarUrl,
    required this.xp,
    required this.level,
    required this.rank,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      rank: json['rank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'xp': xp,
        'level': level,
        'rank': rank,
      };
}
