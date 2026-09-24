import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedModel = ApiService.selectedModel;
  bool _isPinging = false;
  bool _isConnected = false;
  int _latencyMs = 0;
  String _serverStatus = 'Not tested';

  // Stats (will show data from events endpoint)
  int _totalEvents = 0;
  int _totalCrew = 0;
  double _totalSaved = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final events = await ApiService.fetchEvents();
    int crewCount = 0;
    double totalSpent = 0;
    double totalBudget = 0;

    for (final event in events) {
      totalBudget += (event['total_budget'] ?? 0).toDouble();
      final bookings = event['bookings'] as List<dynamic>? ?? [];
      for (final b in bookings) {
        if ((b['status'] ?? '').toString().toUpperCase() == 'CONFIRMED') {
          crewCount++;
          totalSpent += (b['agreed_rate'] ?? 0).toDouble();
        }
      }
    }

    setState(() {
      _totalEvents = events.length;
      _totalCrew = crewCount;
      _totalSaved = totalBudget - totalSpent;
      _statsLoaded = true;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isPinging = true;
      _serverStatus = 'Testing...';
    });

    final result = await ApiService.pingServer();

    setState(() {
      _isPinging = false;
      _isConnected = result['connected'] ?? false;
      _latencyMs = result['latencyMs'] ?? 0;
      _serverStatus = _isConnected
          ? 'Connected (${_latencyMs}ms)'
          : 'Unreachable';
    });
  }

  void _showEditUrlDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.link_rounded, color: AppTheme.primaryLight),
            SizedBox(width: 8),
            Text('Edit Backend URL',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF13102B),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textDarkSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ApiService.setBaseUrl(controller.text.trim());
                setState(() {
                  _serverStatus = 'Not tested';
                  _isConnected = false;
                });
              }
              Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF4834D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withAlpha(50),
                  child: const Text(
                    'HJ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Hackathon Judge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.verified_rounded,
                              color: Colors.white70, size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verified Event Organizer',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📍 Pune, India',
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // AI Engine & Model Preferences
          _buildSectionHeader(
              Icons.auto_awesome_rounded, 'AI Engine & Model Preferences'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E2A50)),
            ),
            child: Column(
              children: [
                _buildModelTile(
                  'gemini-3.5-flash',
                  '⚡ Gemini 3.5 Flash',
                  'Default — Fast inference, quick tool calling',
                ),
                const Divider(
                    color: Color(0xFF2E2A50), height: 1, indent: 16, endIndent: 16),
                _buildModelTile(
                  'gemini-3.6-flash',
                  '🌟 Gemini 3.6 Flash',
                  'Deep reasoning, extended multi-step analysis',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Backend Connection
          _buildSectionHeader(
              Icons.cloud_rounded, 'Backend Connection'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E2A50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dns_rounded,
                        color: AppTheme.textDarkSecondary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ApiService.baseUrl,
                        style: const TextStyle(
                          color: AppTheme.textDarkPrimary,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isConnected
                            ? AppTheme.success
                            : AppTheme.textDarkSecondary,
                        boxShadow: _isConnected
                            ? [
                                BoxShadow(
                                  color: AppTheme.success.withAlpha(120),
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _serverStatus,
                      style: TextStyle(
                        color: _isConnected
                            ? AppTheme.success
                            : AppTheme.textDarkSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isPinging ? null : _testConnection,
                        icon: _isPinging
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryLight,
                                ),
                              )
                            : const Icon(Icons.speed_rounded, size: 16),
                        label: Text(
                          _isPinging ? 'Pinging...' : 'Test Connection',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryLight,
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showEditUrlDialog,
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit URL',
                            style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDarkSecondary,
                          side: const BorderSide(color: Color(0xFF2E2A50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Statistics
          _buildSectionHeader(Icons.bar_chart_rounded, 'Your Statistics'),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard(
                _statsLoaded ? '$_totalEvents' : '...',
                'Events\nPlanned',
                Icons.event_rounded,
                AppTheme.primary,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                _statsLoaded ? '$_totalCrew' : '...',
                'Crew\nHired',
                Icons.people_alt_rounded,
                AppTheme.info,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                _statsLoaded
                    ? (_totalSaved >= 1000
                        ? '₹${(_totalSaved / 1000).toStringAsFixed(1)}K'
                        : '₹${_totalSaved.toStringAsFixed(0)}')
                    : '...',
                'Budget\nSaved',
                Icons.savings_rounded,
                AppTheme.success,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // About Section
          _buildSectionHeader(Icons.info_outline_rounded, 'About CrewMatch AI'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E2A50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CrewMatch AI',
                  style: TextStyle(
                    color: AppTheme.textDarkPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Version 1.0.0 (Build 2026.09)',
                  style: TextStyle(
                    color: AppTheme.textDarkSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTechChip('Flutter'),
                    _buildTechChip('FastAPI'),
                    _buildTechChip('Google Gemini'),
                    _buildTechChip('Supabase'),
                    _buildTechChip('Render'),
                    _buildTechChip('Vercel'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryLight, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textDarkPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildModelTile(String modelId, String title, String subtitle) {
    final isSelected = _selectedModel == modelId;
    return RadioListTile<String>(
      value: modelId,
      groupValue: _selectedModel,
      onChanged: (val) {
        if (val != null) {
          setState(() => _selectedModel = val);
          ApiService.selectedModel = val;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Model switched to $title'),
              backgroundColor: AppTheme.darkCard,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      activeColor: AppTheme.primaryLight,
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.textDarkPrimary : AppTheme.textDarkSecondary,
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textDarkSecondary, fontSize: 12),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E2A50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textDarkPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textDarkSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryLight,
          fontSize: 12,
        ),
      ),
    );
  }
}
