class RecommendedCrewMember {
  final String crewId;
  final String name;
  final String role;
  final double hourlyRate;
  final double estimatedCost;
  final String reason;

  RecommendedCrewMember({
    required this.crewId,
    required this.name,
    required this.role,
    required this.hourlyRate,
    required this.estimatedCost,
    required this.reason,
  });

  factory RecommendedCrewMember.fromJson(Map<String, dynamic> json) {
    return RecommendedCrewMember(
      crewId: json['crew_id'] ?? '',
      name: json['name'] ?? 'Crew Member',
      role: json['role'] ?? 'Specialist',
      hourlyRate: (json['hourly_rate'] ?? 0).toDouble(),
      estimatedCost: (json['estimated_cost'] ?? 0).toDouble(),
      reason: json['reason'] ?? 'Recommended match.',
    );
  }
}

class AlternativeCrewMember {
  final String crewId;
  final String name;
  final String role;
  final double hourlyRate;
  final String reason;
  final String category;

  AlternativeCrewMember({
    required this.crewId,
    required this.name,
    required this.role,
    required this.hourlyRate,
    required this.reason,
    this.category = "Alternative",
  });

  factory AlternativeCrewMember.fromJson(Map<String, dynamic> json) {
    return AlternativeCrewMember(
      crewId: json['crew_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      hourlyRate: (json['hourly_rate'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      category: json['category'] ?? 'Alternative',
    );
  }
}

class BackupCrewMember {
  final String role;
  final String primaryCrewId;
  final String primaryName;
  final String backupCrewId;
  final String backupName;
  final double backupRate;
  final String reason;

  BackupCrewMember({
    required this.role,
    required this.primaryCrewId,
    required this.primaryName,
    required this.backupCrewId,
    required this.backupName,
    required this.backupRate,
    required this.reason,
  });

  factory BackupCrewMember.fromJson(Map<String, dynamic> json) {
    return BackupCrewMember(
      role: json['role'] ?? '',
      primaryCrewId: json['primary_crew_id'] ?? '',
      primaryName: json['primary_name'] ?? '',
      backupCrewId: json['backup_crew_id'] ?? '',
      backupName: json['backup_name'] ?? '',
      backupRate: (json['backup_rate'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
    );
  }
}

class RecommendationResult {
  final String? eventId;
  final List<RecommendedCrewMember> recommendedTeam;
  final double totalCost;
  final double budget;
  final double budgetRemaining;
  final List<AlternativeCrewMember> alternatives;
  final List<BackupCrewMember> backups;

  RecommendationResult({
    this.eventId,
    required this.recommendedTeam,
    required this.totalCost,
    required this.budget,
    required this.budgetRemaining,
    this.alternatives = const [],
    this.backups = const [],
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    var teamList = (json['recommended_team'] as List? ?? [])
        .map((i) => RecommendedCrewMember.fromJson(i))
        .toList();
    var altList = (json['alternatives'] as List? ?? [])
        .map((i) => AlternativeCrewMember.fromJson(i))
        .toList();
    var backupList = (json['backups'] as List? ?? [])
        .map((i) => BackupCrewMember.fromJson(i))
        .toList();

    return RecommendationResult(
      eventId: json['event_id']?.toString(),
      recommendedTeam: teamList,
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      budget: (json['budget'] ?? 0).toDouble(),
      budgetRemaining: (json['budget_remaining'] ?? 0).toDouble(),
      alternatives: altList,
      backups: backupList,
    );
  }
}

class BookedMember {
  final String crewId;
  final String name;
  final String role;
  final String status;

  BookedMember({
    required this.crewId,
    required this.name,
    required this.role,
    this.status = "CONFIRMED",
  });

  factory BookedMember.fromJson(Map<String, dynamic> json) {
    return BookedMember(
      crewId: json['crew_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      status: json['booking']?['status'] ?? 'CONFIRMED',
    );
  }
}

class BookingResult {
  final bool success;
  final int totalRequested;
  final int totalBooked;
  final int totalFailed;
  final List<BookedMember> bookings;

  BookingResult({
    required this.success,
    required this.totalRequested,
    required this.totalBooked,
    required this.totalFailed,
    required this.bookings,
  });

  factory BookingResult.fromJson(Map<String, dynamic> json) {
    var bList = (json['bookings'] as List? ?? [])
        .map((i) => BookedMember.fromJson(i))
        .toList();

    return BookingResult(
      success: json['success'] ?? false,
      totalRequested: json['total_requested'] ?? 0,
      totalBooked: json['total_booked'] ?? 0,
      totalFailed: json['total_failed'] ?? 0,
      bookings: bList,
    );
  }
}

class ChatResponse {
  final bool success;
  final String sessionId;
  final String state;
  final String message;
  final RecommendationResult? recommendation;
  final BookingResult? bookingResult;

  ChatResponse({
    required this.success,
    required this.sessionId,
    required this.state,
    required this.message,
    this.recommendation,
    this.bookingResult,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] ?? false,
      sessionId: json['session_id'] ?? '',
      state: json['state'] ?? 'chatting',
      message: json['message'] ?? '',
      recommendation: json['recommendation'] != null
          ? RecommendationResult.fromJson(json['recommendation'])
          : null,
      bookingResult: json['booking_result'] != null
          ? BookingResult.fromJson(json['booking_result'])
          : null,
    );
  }
}
