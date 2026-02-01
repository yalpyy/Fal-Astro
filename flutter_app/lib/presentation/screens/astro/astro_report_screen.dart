import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/astro_report.dart';
import '../../providers/astro_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/disclaimer_banner.dart';
import '../../widgets/common/loading_overlay.dart';

/// Astro report screen with tabs
class AstroReportScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final String? reportId;

  const AstroReportScreen({
    super.key,
    this.initialType,
    this.reportId,
  });

  @override
  ConsumerState<AstroReportScreen> createState() => _AstroReportScreenState();
}

class _AstroReportScreenState extends ConsumerState<AstroReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    ('natal', 'Kişilik'),
    ('love', 'Aşk'),
    ('career', 'Kariyer'),
    ('monthly', 'Bu Ay'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Set initial tab based on type
    if (widget.initialType != null) {
      final index = _tabs.indexWhere((t) => t.$1 == widget.initialType);
      if (index >= 0) {
        _tabController.index = index;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final generateState = ref.watch(generateReportProvider);

    final zodiacSign = profileState.birthProfile?.zodiacSign;
    final zodiacLabel = zodiacSign != null ? Formatters.zodiacLabel(zodiacSign) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(zodiacLabel ?? 'Astroloji'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
          isScrollable: true,
        ),
      ),
      body: LoadingOverlay(
        isLoading: generateState.isLoading,
        message: 'Raporunuz hazırlanıyor...',
        child: TabBarView(
          controller: _tabController,
          children: _tabs.map((t) {
            return _ReportTab(
              reportType: ReportType.fromString(t.$1),
              onGenerate: () => _generateReport(ReportType.fromString(t.$1)),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _generateReport(ReportType type) {
    ref.read(generateReportProvider.notifier).generateReport(reportType: type);
  }
}

class _ReportTab extends ConsumerWidget {
  final ReportType reportType;
  final VoidCallback onGenerate;

  const _ReportTab({
    required this.reportType,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(astroReportsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Find latest report of this type
    final report = reportsState.reports
        .where((r) => r.reportType == reportType && r.isCompleted)
        .where((r) => r.isValid)
        .firstOrNull;

    if (report == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 64,
                color: colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '${Formatters.reportTypeLabel(reportType.name)} Raporu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Henüz bu türde bir raporunuz yok',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.add),
                label: const Text('Rapor Oluştur'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (report.sunSign != null)
            Row(
              children: [
                Text(
                  Formatters.zodiacLabel(report.sunSign!),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (report.validUntil != null)
                  Text(
                    'Geçerli: ${report.validUntil!.toString().substring(0, 10)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          const SizedBox(height: 16),

          // Main report text
          if (report.reportText != null && report.reportText!.isNotEmpty) ...[
            Text(report.reportText!),
            const SizedBox(height: 24),
          ],

          // Sections
          if (report.sections.personality != null) ...[
            _SectionCard(
              title: 'Kişilik',
              content: report.sections.personality!,
              icon: Icons.person,
              color: Colors.purple,
            ),
          ],
          if (report.sections.love != null) ...[
            _SectionCard(
              title: 'Aşk',
              content: report.sections.love!,
              icon: Icons.favorite,
              color: Colors.pink,
            ),
          ],
          if (report.sections.career != null) ...[
            _SectionCard(
              title: 'Kariyer',
              content: report.sections.career!,
              icon: Icons.work,
              color: Colors.blue,
            ),
          ],
          if (report.sections.thisMonth != null) ...[
            _SectionCard(
              title: 'Bu Ay',
              content: report.sections.thisMonth!,
              icon: Icons.calendar_month,
              color: Colors.teal,
            ),
          ],

          const SizedBox(height: 16),
          const DisclaimerBanner(),
          const SizedBox(height: 16),

          // Regenerate button
          Center(
            child: OutlinedButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.refresh),
              label: const Text('Yeni Rapor Oluştur'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _SectionCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content),
          ],
        ),
      ),
    );
  }
}
