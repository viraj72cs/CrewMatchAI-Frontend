class EventState {
  String? eventType;
  String? eventDate;
  String? startTime;
  String? endTime;
  String? location;
  int? guestCount;
  double? totalBudget;
  List<CrewRequirement> requirements;
  String? eventId;

  EventState({
    this.eventType,
    this.eventDate,
    this.startTime = "17:00:00",
    this.endTime = "23:00:00",
    this.location,
    this.guestCount,
    this.totalBudget,
    List<CrewRequirement>? requirements,
    this.eventId,
  }) : requirements = requirements ?? [];

  bool get isComplete {
    return eventType != null &&
        eventDate != null &&
        location != null &&
        guestCount != null &&
        totalBudget != null;
  }

  double get completionProgress {
    int count = 0;
    if (eventType != null) count++;
    if (eventDate != null) count++;
    if (location != null) count++;
    if (guestCount != null) count++;
    if (totalBudget != null) count++;
    if (requirements.isNotEmpty) count++;
    return count / 6.0;
  }

  void updateFromMap(Map<String, dynamic> data) {
    if (data['event_type'] != null) eventType = data['event_type'].toString();
    if (data['event_date'] != null) eventDate = data['event_date'].toString();
    if (data['start_time'] != null) startTime = data['start_time'].toString();
    if (data['end_time'] != null) endTime = data['end_time'].toString();
    if (data['location'] != null) location = data['location'].toString();
    if (data['guest_count'] != null) {
      guestCount = int.tryParse(data['guest_count'].toString());
    }
    if (data['total_budget'] != null) {
      totalBudget = double.tryParse(data['total_budget'].toString());
    }
    if (data['event_id'] != null) eventId = data['event_id'].toString();
  }
}

class CrewRequirement {
  final String role;
  final int quantity;
  final double? budget;

  CrewRequirement({
    required this.role,
    required this.quantity,
    this.budget,
  });
}
