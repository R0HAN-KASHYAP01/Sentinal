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
import '../../../services/ngo_attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _beneficiaryFormKey = GlobalKey<FormState>();
  final _staffFormKey = GlobalKey<FormState>();

  final _beneficiaryCountController = TextEditingController();
  final _staffCountController = TextEditingController();

  Uint8List? _beneficiaryVideoBytes;
  String? _beneficiaryVideoName;
  Uint8List? _staffVideoBytes;
  String? _staffVideoName;

  bool _submittingBeneficiary = false;
  bool _submittingStaff = false;
  String? _beneficiaryError;
  String? _staffError;

  bool _loadingHistory = true;
  List<AttendanceRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _beneficiaryCountController.dispose();
    _staffCountController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final user = SessionService.instance.currentUser;
    if (user == null) return;
    setState(() => _loadingHistory = true);
    try {
      final records = await NgoAttendanceService.instance.fetchHistory(user.id);
      if (!mounted) return;
      setState(() {
        _history = records;
        _loadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _pickVideo({required bool isBeneficiary}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      if (isBeneficiary) {
        _beneficiaryVideoBytes = file.bytes;
        _beneficiaryVideoName = file.name;
      } else {
        _staffVideoBytes = file.bytes;
        _staffVideoName = file.name;
      }
    });
  }

  Future<void> _submit({required bool isBeneficiary}) async {
    final user = SessionService.instance.currentUser;
    if (user == null) return;

    final formKey = isBeneficiary ? _beneficiaryFormKey : _staffFormKey;
    if (!formKey.currentState!.validate()) return;

    setState(() {
      if (isBeneficiary) {
        _submittingBeneficiary = true;
        _beneficiaryError = null;
      } else {
        _submittingStaff = true;
        _staffError = null;
      }
    });

    try {
      final countText = isBeneficiary ? _beneficiaryCountController.text : _staffCountController.text;
      final count = int.parse(countText.trim());

      String? videoPath;
      final bytes = isBeneficiary ? _beneficiaryVideoBytes : _staffVideoBytes;
      final name = isBeneficiary ? _beneficiaryVideoName : _staffVideoName;
      if (bytes != null && name != null) {
        videoPath = await NgoStorageService.instance.uploadFile(
          folder: 'attendance',
          fileName: name,
          bytes: bytes,
        );
      }

      await NgoAttendanceService.instance.submitAttendance(
        user: user,
        type: isBeneficiary ? AttendanceType.beneficiary : AttendanceType.staff,
        presentCount: count,
        videoEvidencePath: videoPath,
      );

      if (!mounted) return;

      setState(() {
        if (isBeneficiary) {
          _beneficiaryCountController.clear();
          _beneficiaryVideoBytes = null;
          _beneficiaryVideoName = null;
        } else {
          _staffCountController.clear();
          _staffVideoBytes = null;
          _staffVideoName = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isBeneficiary ? 'Beneficiary' : 'Staff'} attendance submitted.')),
      );

      await _loadHistory();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (isBeneficiary) {
          _beneficiaryError = 'Could not submit attendance. Please try again.';
        } else {
          _staffError = 'Could not submit attendance. Please try again.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _submittingBeneficiary = false;
          _submittingStaff = false;
        });
      }
    }
  }

  String? _countValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a count.';
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) return 'Enter a valid number.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Attendance')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "Submit today's headcount for beneficiaries and staff separately.",
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            _buildAttendanceCard(
              title: 'Beneficiary Attendance',
              icon: Icons.diversity_3_outlined,
              formKey: _beneficiaryFormKey,
              countController: _beneficiaryCountController,
              videoName: _beneficiaryVideoName,
              onPickVideo: () => _pickVideo(isBeneficiary: true),
              onSubmit: () => _submit(isBeneficiary: true),
              isSubmitting: _submittingBeneficiary,
              error: _beneficiaryError,
            ),
            const SizedBox(height: 16),

            _buildAttendanceCard(
              title: 'Staff Attendance',
              icon: Icons.badge_outlined,
              formKey: _staffFormKey,
              countController: _staffCountController,
              videoName: _staffVideoName,
              onPickVideo: () => _pickVideo(isBeneficiary: false),
              onSubmit: () => _submit(isBeneficiary: false),
              isSubmitting: _submittingStaff,
              error: _staffError,
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: 'Recent Submissions'),
            const SizedBox(height: 12),

            if (_loadingHistory)
              const LoadingState(message: 'Loading attendance history...')
            else if (_history.isEmpty)
              const EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'No attendance submitted yet',
                message: 'Submitted records will appear here.',
              )
            else
              ..._history.map((record) => _buildHistoryRow(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard({
    required String title,
    required IconData icon,
    required GlobalKey<FormState> formKey,
    required TextEditingController countController,
    required String? videoName,
    required VoidCallback onPickVideo,
    required VoidCallback onSubmit,
    required bool isSubmitting,
    required String? error,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Number present today',
              controller: countController,
              keyboardType: TextInputType.number,
              validator: _countValidator,
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: videoName ?? 'Attach video evidence (optional)',
              icon: Icons.videocam_outlined,
              onPressed: onPickVideo,
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(error, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: isSubmitting ? 'Submitting...' : 'Submit',
              onPressed: isSubmitting ? () {} : onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(AttendanceRecord record) {
    final dateStr = '${record.date.day.toString().padLeft(2, '0')}/'
        '${record.date.month.toString().padLeft(2, '0')}/${record.date.year}';
    final isBeneficiary = record.type == AttendanceType.beneficiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              isBeneficiary ? Icons.diversity_3_outlined : Icons.badge_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBeneficiary ? 'Beneficiary Attendance' : 'Staff Attendance',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(dateStr, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(
              '${record.presentCount}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}