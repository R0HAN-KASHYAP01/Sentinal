import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../app/theme.dart';
import '../../../services/session_service.dart';
import '../../../services/ngo_storage_service.dart';
import '../../../services/ngo_reports_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Uint8List? _attachmentBytes;
  String? _attachmentName;

  bool _isSubmitting = false;
  String? _error;

  bool _loadingReports = true;
  List<NgoReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final user = SessionService.instance.currentUser;
    if (user == null) return;
    setState(() => _loadingReports = true);
    try {
      final reports = await NgoReportsService.instance.fetchReports(user.id);
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _loadingReports = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingReports = false);
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _attachmentBytes = file.bytes;
      _attachmentName = file.name;
    });
  }

  Future<void> _handleSubmit() async {
    final user = SessionService.instance.currentUser;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      String? attachmentPath;
      if (_attachmentBytes != null && _attachmentName != null) {
        attachmentPath = await NgoStorageService.instance.uploadFile(
          folder: 'reports',
          fileName: _attachmentName!,
          bytes: _attachmentBytes!,
        );
      }

      await NgoReportsService.instance.submitReport(
        user: user,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        attachmentPath: attachmentPath,
      );

      if (!mounted) return;

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _attachmentBytes = null;
        _attachmentName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted.')),
      );

      await _loadReports();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not submit report. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Submit a Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Title',
                      controller: _titleController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title.' : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Description (optional)',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: _attachmentName ?? 'Attach file / photo (optional)',
                      icon: Icons.attach_file,
                      onPressed: _pickAttachment,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                    ],
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: _isSubmitting ? 'Submitting...' : 'Submit Report',
                      onPressed: _isSubmitting ? () {} : _handleSubmit,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: 'Submitted Reports'),
            const SizedBox(height: 12),

            if (_loadingReports)
              const LoadingState(message: 'Loading reports...')
            else if (_reports.isEmpty)
              const EmptyState(
                icon: Icons.description_outlined,
                title: 'No reports yet',
                message: 'Reports you submit will appear here.',
              )
            else
              ..._reports.map((report) => _buildReportRow(report)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(NgoReport report) {
    final dateStr = '${report.createdAt.day.toString().padLeft(2, '0')}/'
        '${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                if (report.attachmentPath != null)
                  const Icon(Icons.attach_file, size: 16, color: AppColors.textSecondary),
              ],
            ),
            if (report.description != null && report.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                report.description!,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}