// FILE: lib/features/ngo/presentation/attendance_screen.dart

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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

  final _beneficiaryCountController =
      TextEditingController(text: '45');

  final _staffCountController =
      TextEditingController(text: '10');

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

  DateTime? _lastSubmittedAt;
  String? _lastSubmittedType;

  // ------------------------------------------------------------
  // COLORS
  // ------------------------------------------------------------

  static const Color navy = Color(0xFF123E68);
  static const Color darkBlue = Color(0xFF0D4778);
  static const Color blue = Color(0xFF1769AA);

  static const Color background = Color(0xFFF4F8FB);
  static const Color lightBlue = Color(0xFFEAF4FB);

  static const Color green = Color(0xFF159447);
  static const Color lightGreen = Color(0xFFE4F7EC);

  static const Color greyText = Color(0xFF6B7785);
  static const Color borderColor = Color(0xFFDDE6ED);

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    _beneficiaryCountController.dispose();
    _staffCountController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD HISTORY
  // ------------------------------------------------------------

  Future<void> _loadHistory() async {
    final user = SessionService.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _loadingHistory = false;
      });

      return;
    }

    setState(() {
      _loadingHistory = true;
    });

    try {
      final records =
          await NgoAttendanceService.instance.fetchHistory(user.id);

      if (!mounted) return;

      setState(() {
        _history = records;
        _loadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingHistory = false;
      });
    }
  }

  // ------------------------------------------------------------
  // PICK VIDEO
  // ------------------------------------------------------------

  Future<void> _pickVideo({
    required bool isBeneficiary,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    if (file.bytes == null) {
      return;
    }

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

  // ------------------------------------------------------------
  // SUBMIT ATTENDANCE
  // ------------------------------------------------------------

  Future<void> _submit({
    required bool isBeneficiary,
  }) async {
    final user = SessionService.instance.currentUser;

    if (user == null) {
      _showError('User session not found. Please login again.');
      return;
    }

    final formKey =
        isBeneficiary ? _beneficiaryFormKey : _staffFormKey;

    if (!formKey.currentState!.validate()) {
      return;
    }

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
      final countText = isBeneficiary
          ? _beneficiaryCountController.text
          : _staffCountController.text;

      final count = int.parse(countText.trim());

      String? videoPath;

      final bytes = isBeneficiary
          ? _beneficiaryVideoBytes
          : _staffVideoBytes;

      final name = isBeneficiary
          ? _beneficiaryVideoName
          : _staffVideoName;

      // Upload video if selected
      if (bytes != null && name != null) {
        videoPath =
            await NgoStorageService.instance.uploadFile(
          folder: 'attendance',
          fileName: name,
          bytes: bytes,
        );
      }

      // Submit to Supabase
      await NgoAttendanceService.instance.submitAttendance(
        user: user,
        type: isBeneficiary
            ? AttendanceType.beneficiary
            : AttendanceType.staff,
        presentCount: count,
        videoEvidencePath: videoPath,
      );

      if (!mounted) return;

      final now = DateTime.now();

      setState(() {
        _lastSubmittedAt = now;
        _lastSubmittedType =
            isBeneficiary ? 'Beneficiary' : 'Staff';

        if (isBeneficiary) {
          _beneficiaryVideoBytes = null;
          _beneficiaryVideoName = null;
        } else {
          _staffVideoBytes = null;
          _staffVideoName = null;
        }
      });

      await _loadHistory();

      if (!mounted) return;

      _showSuccess(
        '${isBeneficiary ? 'Beneficiary' : 'Staff'} attendance submitted successfully!',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (isBeneficiary) {
          _beneficiaryError =
              'Could not submit attendance. Please try again.';
        } else {
          _staffError =
              'Could not submit attendance. Please try again.';
        }
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _submittingBeneficiary = false;
        _submittingStaff = false;
      });
    }
  }

  // ------------------------------------------------------------
  // VALIDATOR
  // ------------------------------------------------------------

  String? _countValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a count.';
    }

    final parsed = int.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      return 'Enter a valid number.';
    }

    return null;
  }

  // ------------------------------------------------------------
  // DATE
  // ------------------------------------------------------------

  String _formatDate(DateTime date) {
    const weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ------------------------------------------------------------
  // SUCCESS MESSAGE
  // ------------------------------------------------------------

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: green,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ------------------------------------------------------------
  // ERROR MESSAGE
  // ------------------------------------------------------------

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 27,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        title: const Text(
          'Daily Attendance',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            14,
            10,
            14,
            24,
          ),
          children: [
            // ==================================================
            // DATE HEADER
            // ==================================================

            _buildDateHeader(today),

            const SizedBox(height: 10),

            // ==================================================
            // BENEFICIARY
            // ==================================================

            _buildAttendanceCard(
              title: 'Beneficiary Attendance',
              subtitle:
                  'Enter the number of beneficiaries present today',
              icon: Icons.groups_rounded,
              formKey: _beneficiaryFormKey,
              countController: _beneficiaryCountController,
              videoName: _beneficiaryVideoName,
              onPickVideo: () {
                _pickVideo(isBeneficiary: true);
              },
              onSubmit: () {
                _submit(isBeneficiary: true);
              },
              isSubmitting: _submittingBeneficiary,
              error: _beneficiaryError,
            ),

            const SizedBox(height: 12),

            // ==================================================
            // STAFF
            // ==================================================

            _buildAttendanceCard(
              title: 'Staff Attendance',
              subtitle:
                  'Enter the number of staff members present today',
              icon: Icons.business_rounded,
              formKey: _staffFormKey,
              countController: _staffCountController,
              videoName: _staffVideoName,
              onPickVideo: () {
                _pickVideo(isBeneficiary: false);
              },
              onSubmit: () {
                _submit(isBeneficiary: false);
              },
              isSubmitting: _submittingStaff,
              error: _staffError,
            ),

            const SizedBox(height: 14),

            // ==================================================
            // SUCCESS BOX
            // ==================================================

            if (_lastSubmittedAt != null)
              _buildSuccessBox(),

            const SizedBox(height: 18),

            // ==================================================
            // RECENT SUBMISSIONS
            // ==================================================

            _buildRecentSubmissions(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE HEADER
  // ============================================================

  Widget _buildDateHeader(DateTime today) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 21,
            color: navy,
          ),

          const SizedBox(width: 10),

          Text(
            _formatDate(today),
            style: const TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Today',
              style: TextStyle(
                color: blue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTENDANCE CARD
  // ============================================================

  Widget _buildAttendanceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required GlobalKey<FormState> formKey,
    required TextEditingController countController,
    required String? videoName,
    required VoidCallback onPickVideo,
    required VoidCallback onSubmit,
    required bool isSubmitting,
    required String? error,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // TITLE
            // --------------------------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    icon,
                    color: darkBlue,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: greyText,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // --------------------------------------------------
            // LABEL
            // --------------------------------------------------

            const Text(
              'Number present today',
              style: TextStyle(
                color: greyText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            // --------------------------------------------------
            // COUNT FIELD
            // --------------------------------------------------

            TextFormField(
              controller: countController,
              keyboardType: TextInputType.number,
              validator: _countValidator,
              style: const TextStyle(
                color: navy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(
                    color: borderColor,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(
                    color: borderColor,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(
                    color: blue,
                    width: 1.4,
                  ),
                ),

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                  ),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                  ),
                ),

                errorStyle: const TextStyle(
                  fontSize: 9,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------
            // VIDEO BUTTON
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 35,
              child: Material(
                color: lightBlue,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: onPickVideo,
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_rounded,
                        size: 20,
                        color: darkBlue,
                      ),

                      const SizedBox(width: 7),

                      Flexible(
                        child: Text(
                          videoName ??
                              'Attach video evidence (optional)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: darkBlue,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --------------------------------------------------
            // ERROR
            // --------------------------------------------------

            if (error != null) ...[
              const SizedBox(height: 7),

              Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 10),

            // --------------------------------------------------
            // SUBMIT BUTTON
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF7FA4C1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 19,
                        width: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Submit Attendance',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUCCESS BOX
  // ============================================================

  Widget _buildSuccessBox() {
    final submittedAt = _lastSubmittedAt!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFC9EED8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: const BoxDecoration(
              color: green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_lastSubmittedType ?? 'Attendance'} '
                  'attendance submitted successfully!',
                  style: const TextStyle(
                    color: green,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${_formatDate(submittedAt)} • '
                  '${_formatTime(submittedAt)}',
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT SUBMISSIONS
  // ============================================================

  Widget _buildRecentSubmissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // HEADER
        // ------------------------------------------------------

        Row(
          children: [
            const Text(
              'Recent Submissions',
              style: TextStyle(
                color: navy,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),

            const Spacer(),

            GestureDetector(
              onTap: () {
                // History is already displayed below.
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  color: blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ------------------------------------------------------
        // LOADING
        // ------------------------------------------------------

        if (_loadingHistory)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                ),
              ),
            ),
          )

        // ------------------------------------------------------
        // EMPTY
        // ------------------------------------------------------

        else if (_history.isEmpty)
          _buildEmptyHistory()

        // ------------------------------------------------------
        // HISTORY
        // ------------------------------------------------------

        else
          ..._history.map(
            (record) => _buildHistoryRow(record),
          ),
      ],
    );
  }

  // ============================================================
  // EMPTY HISTORY
  // ============================================================

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 34,
            color: greyText,
          ),

          const SizedBox(height: 8),

          const Text(
            'No attendance submitted yet',
            style: TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'Submitted records will appear here.',
            style: TextStyle(
              color: greyText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY ROW
  // ============================================================

  Widget _buildHistoryRow(
    AttendanceRecord record,
  ) {
    final isBeneficiary =
        record.type == AttendanceType.beneficiary;

    final icon = isBeneficiary
        ? Icons.groups_rounded
        : Icons.business_rounded;

    final title = isBeneficiary
        ? 'Beneficiary Attendance'
        : 'Staff Attendance';

    final date = _formatDate(record.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // ----------------------------------------------------
          // ICON
          // ----------------------------------------------------

          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: isBeneficiary
                  ? const Color(0xFFE6F7EE)
                  : lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isBeneficiary
                  ? green
                  : darkBlue,
            ),
          ),

          const SizedBox(width: 10),

          // ----------------------------------------------------
          // TEXT
          // ----------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  date,
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // COUNT
          // ----------------------------------------------------

          Text(
            '${record.presentCount}',
            style: const TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}