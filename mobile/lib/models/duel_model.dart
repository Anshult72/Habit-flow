class DuelModel {
  final String id;
  final String inviteCode;
  final int entryXP;
  final int durationDays;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? winnerId;
  final String createdBy;
  final String? opponentId;
  final Map<String, dynamic>? creator;
  final Map<String, dynamic>? opponent;
  final List<DuelParticipantModel> participants;
  final List<dynamic>? requests;

  DuelModel({
    required this.id,
    required this.inviteCode,
    required this.entryXP,
    required this.durationDays,
    required this.status,
    this.startDate,
    this.endDate,
    this.winnerId,
    required this.createdBy,
    this.opponentId,
    this.creator,
    this.opponent,
    required this.participants,
    this.requests,
  });

  DuelModel copyWith({
    String? id,
    String? inviteCode,
    int? entryXP,
    int? durationDays,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? winnerId,
    String? createdBy,
    String? opponentId,
    Map<String, dynamic>? creator,
    Map<String, dynamic>? opponent,
    List<DuelParticipantModel>? participants,
    List<dynamic>? requests,
  }) {
    return DuelModel(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      entryXP: entryXP ?? this.entryXP,
      durationDays: durationDays ?? this.durationDays,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      winnerId: winnerId ?? this.winnerId,
      createdBy: createdBy ?? this.createdBy,
      opponentId: opponentId ?? this.opponentId,
      creator: creator ?? this.creator,
      opponent: opponent ?? this.opponent,
      participants: participants ?? this.participants,
      requests: requests ?? this.requests,
    );
  }

  factory DuelModel.fromJson(Map<String, dynamic> json) {
    return DuelModel(
      id: json['id'],
      inviteCode: json['inviteCode'],
      entryXP: json['entryXP'] ?? 0,
      durationDays: json['durationDays'] ?? 7,
      status: json['status'] ?? 'pending',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      winnerId: json['winnerId'],
      createdBy: json['createdBy'],
      opponentId: json['opponentId'],
      creator: json['creator'],
      opponent: json['opponent'],
      participants: (json['participants'] as List? ?? [])
          .map((e) => DuelParticipantModel.fromJson(e))
          .toList(),
      requests: json['requests'] as List?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inviteCode': inviteCode,
      'entryXP': entryXP,
      'durationDays': durationDays,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'winnerId': winnerId,
      'createdBy': createdBy,
      'opponentId': opponentId,
      'creator': creator,
      'opponent': opponent,
      'participants': participants.map((e) => e.toJson()).toList(),
      'requests': requests,
    };
  }
}

class DuelParticipantModel {
  final String id;
  final int progress;
  final String userId;
  final Map<String, dynamic>? user;

  DuelParticipantModel({
    required this.id,
    required this.progress,
    required this.userId,
    this.user,
  });

  factory DuelParticipantModel.fromJson(Map<String, dynamic> json) {
    return DuelParticipantModel(
      id: json['id'],
      progress: json['progress'] ?? 0,
      userId: json['userId'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress': progress,
      'userId': userId,
      'user': user,
    };
  }
}
