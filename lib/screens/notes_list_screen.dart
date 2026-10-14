import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import '../database/app_database.dart';
import '../database/note.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';

class NotesListScreen extends StatefulWidget {
  final AppDatabase database;
  const NotesListScreen({super.key, required this.database});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _notes = [];
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _initShake();
  }

  Future<void> _loadNotes() async {
    final notes = await widget.database.noteDao.getAllNotes();
    setState(() => _notes = notes);
  }

  void _initShake() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () => _confirmDeleteAll(),
      minimumShakeCount: 2,
      shakeSlopTimeMS: 500,
    );
  }

  void _confirmDeleteAll() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF3E8FF),
        title: const Text('Delete All Notes',
            style: TextStyle(color: Color(0xFF7C3AED))),
        content: const Text('Shake detected! Delete all notes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFFAB8DC5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE879AC),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.database.noteDao.deleteAllNotes();
              _loadNotes();
            },
            child:
                const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8B4FE),
        elevation: 0,
        title: const Text(
          '📒 My Notes',
          style: TextStyle(
            color: Color(0xFF4B0082),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined,
                      size: 80, color: Colors.purple.shade200),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet.\nTap + to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, color: Colors.purple.shade300),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _NoteCard(
                  note: note,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditNoteScreen(
                          database: widget.database,
                          note: note,
                        ),
                      ),
                    );
                    _loadNotes();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE879AC),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddNoteScreen(database: widget.database),
            ),
          );
          _loadNotes();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  const _NoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasLocation = note.latitude != null && note.longitude != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            note.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF4B0082),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 12, color: Colors.purple.shade200),
                  const SizedBox(width: 4),
                  Text(
                    note.createdAt,
                    style: TextStyle(
                        fontSize: 11, color: Colors.purple.shade200),
                  ),
                  if (hasLocation) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.location_on,
                        size: 12, color: Colors.pink.shade300),
                    const SizedBox(width: 2),
                    Text(
                      '${note.latitude!.toStringAsFixed(3)}, ${note.longitude!.toStringAsFixed(3)}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.pink.shade300),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right,
              color: Colors.purple.shade200),
        ),
      ),
    );
  }
}
