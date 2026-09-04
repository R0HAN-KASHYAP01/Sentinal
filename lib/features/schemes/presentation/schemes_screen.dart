import 'package:flutter/material.dart';
import '../../../core/widgets/error_start.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../models/scheme.dart';
import '../data/mock_schemes_data.dart';
import '../data/schemes_repository.dart';
import 'scheme_details_screen.dart';
import 'widgets/scheme_card.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  final _repository = SchemesRepository();
  late Future<Map<SchemeType, int>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchSchemeCounts();
  }

  void _reload() {
    setState(() => _future = _repository.fetchSchemeCounts());
  }

  @override
  Widget build(BuildContext context) {
    // Scheme name/description/icon/color stay static config (there's no
    // `schemes` table in the DB — only `scheme_type` on institutes),
    // only the institute counts come from Supabase.
    final schemes = MockSchemesData.schemes;

    return Scaffold(
      appBar: AppBar(title: const Text('Schemes')),
      body: SafeArea(
        child: FutureBuilder<Map<SchemeType, int>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState(message: 'Loading schemes…');
            }
            if (snapshot.hasError) {
              return ErrorStateView(
                message: 'Could not load scheme data.',
                onRetry: _reload,
              );
            }

            final counts = snapshot.data ?? {};

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Text(
                    'Government schemes and their funded institutes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ...schemes.map(
                    (scheme) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SchemeCard(
                        scheme: scheme,
                        instituteCount: counts[scheme.type] ?? 0,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SchemeDetailsScreen(scheme: scheme),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}