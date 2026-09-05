import 'package:flutter/material.dart';
import '../../models/api_models.dart';
import '../../theme/app_theme.dart';

class AlternativesSheet extends StatefulWidget {
  final RecommendationResult recommendation;

  const AlternativesSheet({super.key, required this.recommendation});

  @override
  State<AlternativesSheet> createState() => _AlternativesSheetState();
}

class _AlternativesSheetState extends State<AlternativesSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primaryLight,
            unselectedLabelColor: AppTheme.textDarkSecondary,
            tabs: const [
              Tab(text: "🛡️ Backup Crew"),
              Tab(text: "⚡ Alternatives"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBackupsTab(),
                _buildAlternativesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupsTab() {
    final backups = widget.recommendation.backups;

    if (backups.isEmpty) {
      return const Center(
        child: Text(
          "All primary candidates have 100% verified availability.",
          style: TextStyle(color: AppTheme.textDarkSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: backups.length,
      itemBuilder: (context, index) {
        final b = backups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: const Color(0xFF241F47),
          child: ListTile(
            title: Text(
              "${b.role}: ${b.backupName}",
              style: const TextStyle(
                color: AppTheme.textDarkPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Backup for ${b.primaryName} • Rate: ₹${b.backupRate.toStringAsFixed(0)}/hr\n${b.reason}",
              style: const TextStyle(color: AppTheme.textDarkSecondary),
            ),
            trailing: const ContainerTag(text: "Backup", color: AppTheme.warning),
          ),
        );
      },
    );
  }

  Widget _buildAlternativesTab() {
    final alternatives = widget.recommendation.alternatives;

    if (alternatives.isEmpty) {
      return const Center(
        child: Text(
          "No alternative options required for this budget.",
          style: TextStyle(color: AppTheme.textDarkSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alternatives.length,
      itemBuilder: (context, index) {
        final alt = alternatives[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: const Color(0xFF241F47),
          child: ListTile(
            title: Text(
              "${alt.role}: ${alt.name}",
              style: const TextStyle(
                color: AppTheme.textDarkPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Rate: ₹${alt.hourlyRate.toStringAsFixed(0)}/hr • ${alt.reason}",
              style: const TextStyle(color: AppTheme.textDarkSecondary),
            ),
            trailing: ContainerTag(
              text: alt.category,
              color: alt.category.contains("Budget")
                  ? AppTheme.success
                  : AppTheme.primaryLight,
            ),
          ),
        );
      },
    );
  }
}

class ContainerTag extends StatelessWidget {
  final String text;
  final Color color;

  const ContainerTag({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
