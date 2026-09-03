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
import '../../../core/widgets/status_badge.dart';
import '../../../app/theme.dart';
import '../../../services/session_service.dart';
import '../../../services/ngo_storage_service.dart';
import '../../../services/ngo_camera_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _linkFormKey = GlobalKey<FormState>();
  final _linkLabelController = TextEditingController();
  final _linkUrlController = TextEditingController();

  final _uploadLabelController = TextEditingController();
  Uint8List? _videoBytes;
  String? _videoName;

  bool _submittingLink = false;
  bool _submittingUpload = false;
  String? _linkError;
  String? _uploadError;

  bool _loadingFeeds = true;
  List<NgoCameraFeed> _feeds = [];

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  @override
  void dispose() {
    _linkLabelController.dispose();
    _linkUrlController.dispose();
    _uploadLabelController.dispose();
    super.dispose();
  }

  Future<void> _loadFeeds() async {
    final user = SessionService.instance.currentUser;
    if (user == null) return;
    setState(() => _loadingFeeds = true);
    try {
      final feeds = await NgoCameraService.instance.fetchFeeds(user.id);
      if (!mounted) return;
      setState(() {
        _feeds = feeds;
        _loadingFeeds = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFeeds = false);
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _videoBytes = file.bytes;
      _videoName = file.name;
    });
  }

  Future<void> _submitLiveLink() async {
    final user = SessionService.instance.currentUser;
    if (user == null) return;
    if (!_linkFormKey.currentState!.validate()) return;

    setState(() {
      _submittingLink = true;
      _linkError = null;
    });

    try {
      await NgoCameraService.instance.addLiveLink(
        user: user,
        streamUrl: _linkUrlController.text.trim(),
        label: _linkLabelController.text.trim().isEmpty ? null : _linkLabelController.text.trim(),
      );

      if (!mounted) return;
      _linkLabelController.clear();
      _linkUrlController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live stream link added.')),
      );
      await _loadFeeds();
    } catch (_) {
      if (!mounted) return;
      setState(() => _linkError = 'Could not add link. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _submittingLink = false);
      }
    }
  }

  Future<void> _submitUpload() async {
    final user = SessionService.instance.currentUser;
    if (user == null) return;
    if (_videoBytes == null || _videoName == null) {
      setState(() => _uploadError = 'Please select a video to upload.');
      return;
    }

    setState(() {
      _submittingUpload = true;
      _uploadError = null;
    });

    try {
      final path = await NgoStorageService.instance.uploadFile(
        folder: 'camera',
        fileName: _videoName!,
        bytes: _videoBytes!,
      );

      await NgoCameraService.instance.addUploadedVideo(
        user: user,
        videoPath: path,
        label: _uploadLabelController.text.trim().isEmpty ? null : _uploadLabelController.text.trim(),
      );

      if (!mounted) return;
      _uploadLabelController.clear();
      setState(() {
        _videoBytes = null;
        _videoName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded.')),
      );
      await _loadFeeds();
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadError = 'Could not upload video. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _submittingUpload = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera / Video Access')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Provide camera access as a live stream link, or upload a video directly.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            AppCard(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _linkFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.link, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Add Live Stream Link', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Label (optional, e.g. Main Hall Camera)',
                      controller: _linkLabelController,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Stream URL',
                      controller: _linkUrlController,
                      keyboardType: TextInputType.url,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter a stream URL.';
                        if (!v.trim().startsWith('http') && !v.trim().startsWith('rtsp')) {
                          return 'Enter a valid URL (http/https/rtsp).';
                        }
                        return null;
                      },
                    ),
                    if (_linkError != null) ...[
                      const SizedBox(height: 10),
                      Text(_linkError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                    ],
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: _submittingLink ? 'Adding...' : 'Add Link',
                      onPressed: _submittingLink ? () {} : _submitLiveLink,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.upload_file, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Upload Video', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Label (optional)',
                    controller: _uploadLabelController,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: _videoName ?? 'Select video file',
                    icon: Icons.videocam_outlined,
                    onPressed: _pickVideo,
                  ),
                  if (_uploadError != null) ...[
                    const SizedBox(height: 10),
                    Text(_uploadError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: _submittingUpload ? 'Uploading...' : 'Upload',
                    onPressed: _submittingUpload ? () {} : _submitUpload,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: 'Existing Feeds'),
            const SizedBox(height: 12),

            if (_loadingFeeds)
              const LoadingState(message: 'Loading feeds...')
            else if (_feeds.isEmpty)
              const EmptyState(
                icon: Icons.videocam_off_outlined,
                title: 'No camera feeds yet',
                message: 'Live links and uploaded videos will appear here.',
              )
            else
              ..._feeds.map((feed) => _buildFeedRow(feed)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedRow(NgoCameraFeed feed) {
    final isLive = feed.type == NgoFeedType.liveLink;
    final dateStr = '${feed.createdAt.day.toString().padLeft(2, '0')}/'
        '${feed.createdAt.month.toString().padLeft(2, '0')}/${feed.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              isLive ? Icons.link : Icons.video_file_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feed.label ?? (isLive ? 'Live Stream' : 'Uploaded Video'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(dateStr, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            StatusBadge(
              label: isLive ? 'Live Link' : 'Upload',
              color: isLive ? AppColors.info : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}