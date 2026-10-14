import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/note.dart';

class EditNoteScreen extends StatefulWidget {
  final AppDatabase database;
  final Note note;
  const EditNoteScreen(
      {super.key, required this.database, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = Note(
      id: widget.note.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      latitude: widget.note.latitude,
      longitude: widget.note.longitude,
      createdAt: widget.note.createdAt,
    );

    await widget.database.noteDao.updateNote(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF3E8FF),
        title: const Text('Delete Note',
            style: TextStyle(color: Color(0xFF7C3AED))),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFFAB8DC5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE879AC),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.database.noteDao.deleteNote(widget.note);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        widget.note.latitude != null && widget.note.longitude != null;

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
          '📝 Edit Note',
          style: TextStyle(
            color: Color(0xFF4B0082),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFE879AC)),
            tooltip: 'Delete note',
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Created at info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Colors.purple.shade300),
                    const SizedBox(width: 6),
                    Text(
                      'Created: ${widget.note.createdAt}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.purple.shade400),
                    ),
                    if (hasLocation) ...[
                      const Spacer(),
                      Icon(Icons.location_on,
                          size: 14, color: Colors.pink.shade300),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.note.latitude!.toStringAsFixed(3)}, ${widget.note.longitude!.toStringAsFixed(3)}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.pink.shade300),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title
              _buildLabel('Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Note title...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              // Content
              _buildLabel('Content'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: _inputDecoration('Note content...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Content is required'
                        : null,
              ),
              const SizedBox(height: 32),

              // Update button
              ElevatedButton.icon(
                onPressed: _updateNote,
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.white),
                label: const Text(
                  'Update Note',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD8B4FE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
              const SizedBox(height: 12),

              // Delete button
              OutlinedButton.icon(
                onPressed: _deleteNote,
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFFE879AC)),
                label: const Text(
                  'Delete Note',
                  style: TextStyle(
                      color: Color(0xFFE879AC),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: Color(0xFFE879AC), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
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
