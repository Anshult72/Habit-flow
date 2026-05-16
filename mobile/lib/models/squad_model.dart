class SquadModel {
  final String id;
  final String name;
  final String inviteCode;
  final int entryXP;
  final int durationDays;
  final String status;
  final Map<String, dynamic>? creator;
  final List<SquadMemberModel> members;
  final List<dynamic>? requests;

  SquadModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.entryXP,
    required this.durationDays,
    required this.status,
    this.creator,
    required this.members,
    this.requests,
  });

  factory SquadModel.fromJson(Map<String, dynamic> json) {
    return SquadModel(
      id: json['id'],
      name: json['name'],
      inviteCode: json['inviteCode'],
      entryXP: json['entryXP'] ?? 0,
      durationDays: json['durationDays'] ?? 7,
      status: json['status'] ?? 'pending',
      creator: json['creator'],
      members: (json['members'] as List? ?? [])
          .map((e) => SquadMemberModel.fromJson(e))
          .toList(),
      requests: json['requests'] as List?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'inviteCode': inviteCode,
        'entryXP': entryXP,
        'durationDays': durationDays,
        'status': status,
        'creator': creator,
        'members': members.map((e) => e.toJson()).toList(),
        'requests': requests,
      };
}

class SquadMemberModel {
  final String id;
  final String role;
  final String userId;
  final Map<String, dynamic>? user;

  SquadMemberModel({
    required this.id,
    required this.role,
    required this.userId,
    this.user,
  });

  factory SquadMemberModel.fromJson(Map<String, dynamic> json) {
    return SquadMemberModel(
      id: json['id'],
      role: json['role'] ?? 'member',
      userId: json['userId'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'userId': userId,
        'user': user,
      };
}
