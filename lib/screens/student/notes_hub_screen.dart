import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/note_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state_view.dart';

class NotesHubScreen extends StatefulWidget {
  const NotesHubScreen({super.key});

  @override
  State<NotesHubScreen> createState() => _NotesHubScreenState();
}

class _NotesHubScreenState extends State<NotesHubScreen> {
  String _selectedSubject = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Study Materials'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, student, _) {
          if (student.isLoadingNotes && student.notes.isEmpty) {
            return const LoadingIndicator(message: 'Loading course study materials...');
          }

          final allNotes = student.notes;
          final subjects = allNotes.map((n) => n.subject).toSet().toList();
          final filtered = _selectedSubject == 'All'
              ? allNotes
              : allNotes.where((n) => n.subject == _selectedSubject).toList();

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => student.fetchNotes(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', _selectedSubject == 'All', () => setState(() => _selectedSubject = 'All')),
                        ...subjects.map((s) => _filterChip(s, _selectedSubject == s, () => setState(() => _selectedSubject = s))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (filtered.isEmpty)
                    const EmptyStateView(
                      title: 'No notes uploaded yet',
                      message: 'Check back later for faculty notes and lecture summaries.',
                      icon: Icons.menu_book_outlined,
                    )
                  else
                    ...filtered.map((note) => _buildNoteCard(note, isDark)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
        selected: isSelected,
        selectedColor: AppColors.brand500,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brand500.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    note.type.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brand500),
                  ),
                ),
                Text(
                  note.date,
                  style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.topic,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${note.subject} · By ${note.faculty}',
              style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
            ),
            if (note.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.description,
                style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk700 : AppColors.lightInk700),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Download Resource'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading "${note.topic}" material...')),
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
