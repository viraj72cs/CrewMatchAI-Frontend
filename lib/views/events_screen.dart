import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> _allEvents = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await ApiService.fetchEvents();
    setState(() {
      _allEvents = events;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedFilter == 'All') return _allEvents;
    if (_selectedFilter == 'Upcoming') {
      return _allEvents
          .where((e) =>
              (e['status'] ?? '').toString().toUpperCase() == 'CONFIRMED' ||
              (e['status'] ?? '').toString().toUpperCase() == 'PLANNING')
          .toList();
    }
    if (_selectedFilter == 'Completed') {
      return _allEvents
          .where((e) =>
              (e['status'] ?? '').toString().toUpperCase() == 'COMPLETED')
          .toList();
    }
    return _allEvents;
  }

  int get _totalCrewCount {
    int count = 0;
    for (final event in _allEvents) {
      final bookings = event['bookings'] as List<dynamic>? ?? [];
      count += bookings
          .where((b) =>
              (b['status'] ?? '').toString().toUpperCase() == 'CONFIRMED')
          .length;
    }
    return count;
  }

  double get _totalSpent {
    double total = 0;
    for (final event in _allEvents) {
      final bookings = event['bookings'] as List<dynamic>? ?? [];
      for (final b in bookings) {
        if ((b['status'] ?? '').toString().toUpperCase() == 'CONFIRMED') {
          total += (b['agreed_rate'] ?? 0).toDouble();
        }
      }
    }
    return total;
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return AppTheme.success;
      case 'PLANNING':
        return AppTheme.warning;
      case 'COMPLETED':
        return AppTheme.primaryLight;
      case 'CANCELLED':
        return AppTheme.error;
      default:
        return AppTheme.textDarkSecondary;
    }
  }

  IconData _eventTypeIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('wedding')) return Icons.favorite_rounded;
    if (lower.contains('corporate') || lower.contains('conference')) {
      return Icons.business_rounded;
    }
    if (lower.contains('birthday')) return Icons.cake_rounded;
    if (lower.contains('party')) return Icons.celebration_rounded;
    return Icons.event_rounded;
  }

  void _showEventDetail(Map<String, dynamic> event) {
    final bookings = event['bookings'] as List<dynamic>? ?? [];
    final budget = (event['total_budget'] ?? 0).toDouble();
    double spent = 0;
    for (final b in bookings) {
      if ((b['status'] ?? '').toString().toUpperCase() == 'CONFIRMED') {
        spent += (b['agreed_rate'] ?? 0).toDouble();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _eventTypeIcon(event['event_type'] ?? ''),
                            color: AppTheme.primaryLight,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${event['event_type'] ?? 'Event'}',
                                style: const TextStyle(
                                  color: AppTheme.textDarkPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '📅 ${event['event_date'] ?? 'TBD'}  📍 ${event['location'] ?? 'TBD'}',
                                style: const TextStyle(
                                  color: AppTheme.textDarkSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Budget Bar
                    _buildBudgetBar(spent, budget),
                    const SizedBox(height: 20),

                    // Crew Roster Header
                    Text(
                      'Crew Roster (${bookings.length} members)',
                      style: const TextStyle(
                        color: AppTheme.textDarkPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (bookings.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13102B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No crew booked yet for this event.',
                            style: TextStyle(
                                color: AppTheme.textDarkSecondary),
                          ),
                        ),
                      )
                    else
                      ...bookings.map((b) {
                        final bStatus =
                            (b['status'] ?? 'UNKNOWN').toString().toUpperCase();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13102B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                bStatus == 'CONFIRMED'
                                    ? Icons.verified_rounded
                                    : Icons.cancel_rounded,
                                color: bStatus == 'CONFIRMED'
                                    ? AppTheme.success
                                    : AppTheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b['crew_name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: AppTheme.textDarkPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      b['role'] ?? 'Specialist',
                                      style: const TextStyle(
                                        color: AppTheme.textDarkSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${(b['agreed_rate'] ?? 0).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _statusColor(bStatus).withAlpha(30),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      bStatus,
                                      style: TextStyle(
                                        color: _statusColor(bStatus),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

    return Column(
      children: [
        // Filter Tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: ['All', 'Upcoming', 'Completed'].map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppTheme.textDarkSecondary,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.darkCard,
                  side: BorderSide(
                    color:
                        isSelected ? AppTheme.primary : const Color(0xFF2E2A50),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Summary Metrics
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2E2A50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryMetric(
                    '${_allEvents.length}', 'Events', Icons.event_rounded),
                Container(width: 1, height: 30, color: const Color(0xFF2E2A50)),
                _buildSummaryMetric(
                    '$_totalCrewCount', 'Crew', Icons.people_alt_rounded),
                Container(width: 1, height: 30, color: const Color(0xFF2E2A50)),
                _buildSummaryMetric(
                  _totalSpent >= 100000
                      ? '₹${(_totalSpent / 100000).toStringAsFixed(1)}L'
                      : '₹${_totalSpent.toStringAsFixed(0)}',
                  'Spent',
                  Icons.currency_rupee_rounded,
                ),
              ],
            ),
          ),
        ),

        // Event Cards List
        Expanded(
          child: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryLight))
              : events.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      color: AppTheme.primaryLight,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return _buildEventCard(events[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSummaryMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryLight, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textDarkPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textDarkSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final type = event['event_type'] ?? 'Event';
    final date = event['event_date'] ?? 'TBD';
    final location = event['location'] ?? '';
    final status = (event['status'] ?? 'PLANNING').toString().toUpperCase();
    final bookings = event['bookings'] as List<dynamic>? ?? [];
    final budget = (event['total_budget'] ?? 0).toDouble();
    final guests = event['guest_count'] ?? 0;

    double spent = 0;
    int confirmedCount = 0;
    for (final b in bookings) {
      if ((b['status'] ?? '').toString().toUpperCase() == 'CONFIRMED') {
        spent += (b['agreed_rate'] ?? 0).toDouble();
        confirmedCount++;
      }
    }

    return GestureDetector(
      onTap: () => _showEventDetail(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E2A50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _eventTypeIcon(type),
                    color: AppTheme.primaryLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          color: AppTheme.textDarkPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📅 $date  📍 $location',
                        style: const TextStyle(
                          color: AppTheme.textDarkSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Crew + Guests Row
            Row(
              children: [
                Icon(Icons.people_alt_rounded,
                    color: AppTheme.textDarkSecondary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$confirmedCount crew  •  $guests guests',
                  style: const TextStyle(
                      color: AppTheme.textDarkSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Budget Progress Bar
            _buildBudgetBar(spent, budget),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEventDetail(event),
                    icon: const Icon(Icons.groups_rounded, size: 16),
                    label: const Text('View Team', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryLight,
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatScreen()),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label:
                        const Text('Manage Crew', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetBar(double spent, double budget) {
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final savings = budget - spent;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${spent.toStringAsFixed(0)} spent',
              style:
                  const TextStyle(color: AppTheme.textDarkSecondary, fontSize: 12),
            ),
            Text(
              '₹${budget.toStringAsFixed(0)} budget',
              style:
                  const TextStyle(color: AppTheme.textDarkSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF2E2A50),
            valueColor: AlwaysStoppedAnimation<Color>(
              savings >= 0 ? AppTheme.success : AppTheme.error,
            ),
            minHeight: 6,
          ),
        ),
        if (savings >= 0) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '💰 ₹${savings.toStringAsFixed(0)} savings',
              style: const TextStyle(
                color: AppTheme.success,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded,
              color: AppTheme.primary.withAlpha(100), size: 64),
          const SizedBox(height: 12),
          const Text(
            'No events found',
            style: TextStyle(
              color: AppTheme.textDarkPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Plan your first event with AI!',
            style: TextStyle(color: AppTheme.textDarkSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Start Planning'),
          ),
        ],
      ),
    );
  }
}
