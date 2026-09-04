import 'package:flutter/material.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_start.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../models/institute.dart';
import '../../../models/scheme.dart';
import '../data/schemes_repository.dart';
import 'institute_details_screen.dart';
import 'widgets/institute_list_item.dart';

class SchemeDetailsScreen extends StatefulWidget {
  final Scheme scheme;
  const SchemeDetailsScreen({super.key, required this.scheme});

  @override
  State<SchemeDetailsScreen> createState() => _SchemeDetailsScreenState();
}

class _SchemeDetailsScreenState extends State<SchemeDetailsScreen> {
  final _repository = SchemesRepository();
  late Future<List<Institute>> _future;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchInstitutesForScheme(widget.scheme.type);
  }

  void _reload() {
    setState(() => _future = _repository.fetchInstitutesForScheme(widget.scheme.type));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Institute> _applyFilter(List<Institute> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.location.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.scheme.name)),
      body: SafeArea(
        child: FutureBuilder<List<Institute>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState(message: 'Loading institutes…');
            }
            if (snapshot.hasError) {
              return ErrorStateView(
                message: 'Could not load institutes for this scheme.',
                onRetry: _reload,
              );
            }

            final all = snapshot.data ?? [];
            final results = _applyFilter(all);

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.scheme.description, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText: 'Search institutes by name, location, or category',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: results.isEmpty
                        ? ListView(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 48),
                                child: EmptyState(
                                  icon: Icons.search_off,
                                  title: 'No institutes found',
                                  message: 'Try adjusting your search, or pull to refresh.',
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            itemCount: results.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final institute = results[index];
                              return InstituteListItem(
                                institute: institute,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => InstituteDetailsScreen(institute: institute),
                                    ),
                                  );
                                },
                              );
                            },
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