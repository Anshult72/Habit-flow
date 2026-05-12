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
}
