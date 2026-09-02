import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/project.dart';
import '../data/mock_projects_data.dart';
import 'project_details_screen.dart';
import 'widgets/project_list_item.dart';

enum _ProjectFilter { all, active, underReview, highRisk }

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _ProjectFilter _filter = _ProjectFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> get _filteredProjects {
    return MockProjectsData.projects.where((p) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q) ||
          p.type.toLowerCase().contains(q);

      final matchesFilter = switch (_filter) {
        _ProjectFilter.all => true,
        _ProjectFilter.active => p.status == ProjectStatus.active,
        _ProjectFilter.underReview => p.status == ProjectStatus.underReview,
        _ProjectFilter.highRisk => p.riskLevel == RiskLevel.high,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  Widget _filterChip(String label, _ProjectFilter value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredProjects;

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitor registered projects and institutions',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search by name, location, or type',
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
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', _ProjectFilter.all),
                        _filterChip('Active', _ProjectFilter.active),
                        _filterChip('Under Review', _ProjectFilter.underReview),
                        _filterChip('High Risk', _ProjectFilter.highRisk),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: results.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: 'No projects found',
                        message: 'Try adjusting your search or filters.',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final project = results[index];
                        return ProjectListItem(
                          project: project,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProjectDetailsScreen(project: project),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}