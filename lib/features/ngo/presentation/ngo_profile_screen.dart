import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../models/ngo_institute_profile.dart';
import '../../../services/ngo_institute_service.dart';
import '../../../services/session_service.dart';

class NgoProfileScreen extends StatefulWidget {
  const NgoProfileScreen({super.key});

  @override
  State<NgoProfileScreen> createState() => _NgoProfileScreenState();
}

class _NgoProfileScreenState extends State<NgoProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationController = TextEditingController();
  final _addressController = TextEditingController();

  NgoSchemeType? _selectedScheme;
  double? _latitude;
  double? _longitude;

  bool _loadingProfile = true;
  bool _saving = false;
  bool _detectingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingProfile() async {
    final user = SessionService.instance.currentUser;
    if (user == null) {
      setState(() => _loadingProfile = false);
      return;
    }

    try {
      final profile = await NgoInstituteService.instance.fetchProfile(user.id);
      if (!mounted) return;
      if (profile != null) {
        _registrationController.text = profile.registrationNumber ?? '';
        _addressController.text = profile.address ?? '';
        setState(() {
          _selectedScheme = profile.schemeType;
          _latitude = profile.latitude;
          _longitude = profile.longitude;
        });
      }
    } catch (_) {
      // First-time institutes won't have a row yet — that's fine.
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _detectLocation() async {
    setState(() {
      _detectingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are turned off on this device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. Enable it from app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Best-effort reverse geocode to pre-fill the address field.
      // Non-fatal if it fails — the coordinates are still captured.
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          final parts = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.postalCode,
            p.country,
          ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
          if (parts.isNotEmpty) {
            _addressController.text = parts;
          }
        }
      } catch (_) {
        // Ignore reverse-geocode failures — coordinates already captured.
      }
    } catch (e) {
      setState(() => _locationError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedScheme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a scheme.')),
      );
      return;
    }

    final user = SessionService.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final profile = NgoInstituteProfile(
        profileId: user.id,
        registrationNumber: _registrationController.text.trim().isEmpty
            ? null
            : _registrationController.text.trim(),
        schemeType: _selectedScheme,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      await NgoInstituteService.instance.upsertProfile(profile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Institute Profile')),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Scheme',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<NgoSchemeType>(
                      initialValue: _selectedScheme,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select the scheme this institute falls under',
                      ),
                      items: NgoSchemeType.values
                          .map(
                            (scheme) => DropdownMenuItem(
                              value: scheme,
                              child: Text(scheme.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _selectedScheme = value),
                      validator: (value) =>
                          value == null ? 'Please select a scheme' : null,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Registration Number',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _registrationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g. NGO/2024/00123',
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Address',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Registered office / operating address',
                      ),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: _detectingLocation ? null : _detectLocation,
                      icon: _detectingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _detectingLocation
                            ? 'Detecting location...'
                            : 'Detect My Location',
                      ),
                    ),
                    if (_locationError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _locationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                    if (_latitude != null && _longitude != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lat: ${_latitude!.toStringAsFixed(6)}, '
                                'Lng: ${_longitude!.toStringAsFixed(6)}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}