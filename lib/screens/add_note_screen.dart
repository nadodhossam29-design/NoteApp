import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../database/app_database.dart';
import '../database/note.dart';

class AddNoteScreen extends StatefulWidget {
  final AppDatabase database;
  const AddNoteScreen({super.key, required this.database});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _useLocation = false;
  bool _loadingLocation = false;
  double? _latitude;
  double? _longitude;

  Future<void> _fetchLocation() async {
    setState(() => _loadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled.');
        setState(() => _useLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Location permission denied.');
          setState(() => _useLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied.');
        setState(() => _useLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      _showSnack('Could not get location: $e');
      setState(() => _useLocation = false);
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final createdAt =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)} ${_pad(now.hour)}:${_pad(now.minute)}';

    final note = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      latitude: _useLocation ? _latitude : null,
      longitude: _useLocation ? _longitude : null,
      createdAt: createdAt,
    );

    await widget.database.noteDao.insertNote(note);
    if (mounted) Navigator.pop(context);
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8B4FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF4B0082)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '✏️ Add Note',
          style: TextStyle(
            color: Color(0xFF4B0082),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              _buildLabel('Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Enter note title...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              // Content field
              _buildLabel('Content'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: _inputDecoration('Write your note here...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Content is required' : null,
              ),
              const SizedBox(height: 24),

              // Location checkbox
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
                ),
                child: CheckboxListTile(
                  value: _useLocation,
                  activeColor: const Color(0xFFE879AC),
                  checkColor: Colors.white,
                  title: const Text(
                    'Attach my location',
                    style: TextStyle(
                      color: Color(0xFF4B0082),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: _loadingLocation
                      ? const Text('Getting location...',
                          style: TextStyle(color: Colors.grey))
                      : (_latitude != null
                          ? Text(
                              '📍 ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                              style: TextStyle(
                                  color: Colors.pink.shade400, fontSize: 12),
                            )
                          : const Text('Optional',
                              style: TextStyle(color: Colors.grey))),
                  secondary: _loadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE879AC),
                          ),
                        )
                      : Icon(Icons.location_on_outlined,
                          color: _useLocation
                              ? const Color(0xFFE879AC)
                              : Colors.grey),
                  onChanged: (val) async {
                    setState(() => _useLocation = val ?? false);
                    if (_useLocation) await _fetchLocation();
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton.icon(
                onPressed: _loadingLocation ? null : _saveNote,
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text(
                  'Save Note',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE879AC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF4B0082),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8B4FE), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8B4FE), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE879AC), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
