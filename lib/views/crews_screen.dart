import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class CrewsScreen extends StatefulWidget {
  const CrewsScreen({super.key});

  @override
  State<CrewsScreen> createState() => _CrewsScreenState();
}

class _CrewsScreenState extends State<CrewsScreen> {
  List<Map<String, dynamic>> _allCrews = [];
  List<Map<String, dynamic>> _filteredCrews = [];
  String _selectedRole = 'All';
  String _sortBy = 'rating';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<String> _roles = [
    'All',
    'Photographer',
    'Decorator',
    'Sound Engineer',
    'Anchor',
    'Security',
    'Caterer',
  ];

  final Map<String, IconData> _roleIcons = {
    'Photographer': Icons.camera_alt_rounded,
    'Decorator': Icons.palette_rounded,
    'Sound Engineer': Icons.graphic_eq_rounded,
    'Anchor': Icons.mic_rounded,
    'Security': Icons.shield_rounded,
    'Caterer': Icons.restaurant_rounded,
  };

  @override
  void initState() {
    super.initState();
    _loadCrews();
  }

  Future<void> _loadCrews() async {
    setState(() => _isLoading = true);
    final crews = await ApiService.fetchCrews();
    setState(() {
      _allCrews = crews;
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(_allCrews);

    // Role filter
    if (_selectedRole != 'All') {
      result = result
          .where((c) =>
              (c['primary_role'] ?? '').toString().toLowerCase() ==
              _selectedRole.toLowerCase())
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((c) {
        final name = (c['name'] ?? '').toString().toLowerCase();
        final role = (c['primary_role'] ?? '').toString().toLowerCase();
        final skills = (c['skills'] as List<dynamic>? ?? [])
            .map((s) => (s['skill'] ?? '').toString().toLowerCase())
            .join(' ');
        return name.contains(query) ||
            role.contains(query) ||
            skills.contains(query);
      }).toList();
    }

    // Sort
    if (_sortBy == 'rating') {
      result.sort((a, b) =>
          ((b['rating'] ?? 0) as num).compareTo((a['rating'] ?? 0) as num));
    } else if (_sortBy == 'gigs') {
      result.sort((a, b) => ((b['completed_gigs'] ?? 0) as num)
          .compareTo((a['completed_gigs'] ?? 0) as num));
    } else if (_sortBy == 'rate_low') {
      result.sort((a, b) => ((a['hourly_rate'] ?? 0) as num)
          .compareTo((b['hourly_rate'] ?? 0) as num));
    } else if (_sortBy == 'reliability') {
      result.sort((a, b) => ((b['reliability_score'] ?? 0) as num)
          .compareTo((a['reliability_score'] ?? 0) as num));
    }

    setState(() => _filteredCrews = result);
  }

  void _showCrewDetail(Map<String, dynamic> crew) {
    final skills = crew['skills'] as List<dynamic>? ?? [];
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
                    // Profile Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.primary,
                          child: Text(
                            (crew['name'] ?? 'C')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      crew['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: AppTheme.textDarkPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded,
                                      color: AppTheme.info, size: 18),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                crew['primary_role'] ?? 'Specialist',
                                style: const TextStyle(
                                  color: AppTheme.primaryLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatChip(
                            '⭐ ${(crew['rating'] ?? 0).toStringAsFixed(1)}',
                            AppTheme.warning),
                        const SizedBox(width: 8),
                        _buildStatChip(
                            '🎯 ${crew['completed_gigs'] ?? 0} gigs',
                            AppTheme.success),
                        const SizedBox(width: 8),
                        _buildStatChip(
                            '🛡️ ${crew['reliability_score'] ?? 0}%',
                            AppTheme.info),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Details
                    _buildDetailRow(Icons.work_history_rounded,
                        '${crew['experience_years'] ?? 0} years experience'),
                    const SizedBox(height: 10),
                    _buildDetailRow(Icons.currency_rupee_rounded,
                        '₹${(crew['hourly_rate'] ?? 0).toStringAsFixed(0)} / hour'),
                    const SizedBox(height: 10),
                    _buildDetailRow(Icons.cancel_rounded,
                        '${crew['no_show_count'] ?? 0} no-shows'),
                    const SizedBox(height: 20),

                    // Skills Section
                    const Text(
                      'Skills & Expertise',
                      style: TextStyle(
                        color: AppTheme.textDarkPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (skills.isEmpty)
                      const Text(
                        'No skills listed yet.',
                        style: TextStyle(color: AppTheme.textDarkSecondary),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skills.map<Widget>((s) {
                          final level = s['skill_level'] ?? 'Intermediate';
                          final color = level == 'Expert'
                              ? AppTheme.success
                              : level == 'Advanced'
                                  ? AppTheme.info
                                  : AppTheme.warning;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withAlpha(80)),
                            ),
                            child: Text(
                              '${s['skill'] ?? ''} • $level',
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('Request in AI Planner'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textDarkSecondary, size: 18),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
                color: AppTheme.textDarkPrimary, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (val) {
              _searchQuery = val;
              _applyFilters();
            },
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.darkCard,
              hintText: 'Search by name, role, or skill...',
              hintStyle: const TextStyle(color: AppTheme.textDarkSecondary),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppTheme.primaryLight),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2E2A50)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2E2A50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primary),
              ),
            ),
          ),
        ),

        // Role Filter Chips
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final role = _roles[index];
              final isSelected = _selectedRole == role;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    role,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDarkSecondary,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.darkCard,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : const Color(0xFF2E2A50),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedRole = role);
                    _applyFilters();
                  },
                ),
              );
            },
          ),
        ),

        // Sort Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(color: AppTheme.textDarkSecondary, fontSize: 13),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E2A50)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: AppTheme.darkCard,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(
                          value: 'rating', child: Text('⭐ Highest Rated')),
                      DropdownMenuItem(
                          value: 'gigs', child: Text('🎯 Most Experienced')),
                      DropdownMenuItem(
                          value: 'rate_low', child: Text('💰 Rate: Low → High')),
                      DropdownMenuItem(
                          value: 'reliability', child: Text('🛡️ Reliability')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _sortBy = val);
                        _applyFilters();
                      }
                    },
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredCrews.length} specialists',
                style: const TextStyle(
                    color: AppTheme.textDarkSecondary, fontSize: 13),
              ),
            ],
          ),
        ),

        // Crew Cards List
        Expanded(
          child: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryLight))
              : _filteredCrews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search_rounded,
                              color: AppTheme.primary.withAlpha(100), size: 64),
                          const SizedBox(height: 12),
                          const Text(
                            'No crew members found',
                            style: TextStyle(
                                color: AppTheme.textDarkSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCrews,
                      color: AppTheme.primaryLight,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        itemCount: _filteredCrews.length,
                        itemBuilder: (context, index) {
                          return _buildCrewCard(_filteredCrews[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCrewCard(Map<String, dynamic> crew) {
    final role = crew['primary_role'] ?? 'Specialist';
    final icon = _roleIcons[role] ?? Icons.person_rounded;
    final skills = crew['skills'] as List<dynamic>? ?? [];
    final rating = (crew['rating'] ?? 0).toDouble();
    final gigs = crew['completed_gigs'] ?? 0;
    final reliability = crew['reliability_score'] ?? 0;
    final rate = (crew['hourly_rate'] ?? 0).toDouble();

    return GestureDetector(
      onTap: () => _showCrewDetail(crew),
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
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primary.withAlpha(50),
                  child: Icon(icon, color: AppTheme.primaryLight, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              crew['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: AppTheme.textDarkPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              color: AppTheme.info, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: const TextStyle(
                          color: AppTheme.textDarkSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₹${rate.toStringAsFixed(0)}/hr',
                    style: const TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metrics row
            Row(
              children: [
                _buildMetricPill('⭐ ${rating.toStringAsFixed(1)}'),
                const SizedBox(width: 8),
                _buildMetricPill('🎯 $gigs gigs'),
                const SizedBox(width: 8),
                _buildMetricPill('🛡️ $reliability%'),
              ],
            ),

            // Skills tags
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: skills.take(4).map<Widget>((s) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s['skill'] ?? '',
                      style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF13102B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textDarkSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
