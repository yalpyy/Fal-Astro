import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../providers/fortune_provider.dart';
import '../../providers/astro_provider.dart';
import '../../router/route_names.dart';

/// History screen with tabs for fortunes and astro reports
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data
    Future.microtask(() {
      ref.read(fortuneListProvider.notifier).loadReadings(refresh: true);
      ref.read(astroReportsProvider.notifier).loadReports(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Fallar'),
            Tab(text: 'Astro Raporları'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FortuneHistoryTab(),
          _AstroHistoryTab(),
        ],
      ),
    );
  }
}

class _FortuneHistoryTab extends ConsumerWidget {
  const _FortuneHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fortuneListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.readings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text('Henüz fal baktırmadınız'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.pushNamed(RouteNames.fortuneUpload),
              child: const Text('İlk Falını Baktır'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(fortuneListProvider.notifier).loadReadings(refresh: true);
      },
      child: ListView.builder(
        itemCount: state.readings.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.readings.length) {
            // Load more
            ref.read(fortuneListProvider.notifier).loadReadings();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final reading = state.readings[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.coffee),
            ),
            title: Text(Formatters.intentLabel(reading.intent.name)),
            subtitle: Text(reading.createdAt.toRelativeString()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(
              RouteNames.fortuneDetail,
              pathParameters: {'id': reading.id},
            ),
          );
        },
      ),
    );
  }
}

class _AstroHistoryTab extends ConsumerWidget {
  const _AstroHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(astroReportsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text('Henüz rapor oluşturmadınız'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.pushNamed(RouteNames.astroReport),
              child: const Text('İlk Raporunu Oluştur'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(astroReportsProvider.notifier).loadReports(refresh: true);
      },
      child: ListView.builder(
        itemCount: state.reports.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.reports.length) {
            ref.read(astroReportsProvider.notifier).loadReports();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final report = state.reports[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.stars),
            ),
            title: Text(Formatters.reportTypeLabel(report.reportType.name)),
            subtitle: Text(report.createdAt.toRelativeString()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(
              RouteNames.astroReportDetail,
              pathParameters: {'id': report.id},
            ),
          );
        },
      ),
    );
  }
}
