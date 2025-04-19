import 'package:flutter/material.dart';
import '../model/Note.dart';
import '../view/NoteItem.dart';
import '../view/NoteDetailScreen.dart';
import '../view/NoteForm.dart';
import '../db/NoteDatabaseHelper.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteDatabaseHelper db = NoteDatabaseHelper();
  List<Note> _notes = [];
  String _searchQuery = '';
  int? _filterPriority;
  bool _isGrid = false;
  bool _isLoading = false;
  String _sortBy = 'modifiedAt'; // Sắp xếp theo thời gian sửa đổi mặc định

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      List<Note> notes;
      if (_searchQuery.isNotEmpty) {
        notes = await db.searchNotes(_searchQuery);
      } else if (_filterPriority != null) {
        notes = await db.getNotesByPriority(_filterPriority!);
      } else {
        notes = await db.getAllNotes();
      }

      // Sắp xếp notes
      notes.sort((a, b) {
        if (_sortBy == 'priority') {
          return b.priority.compareTo(a.priority);
        }
        return b.modifiedAt.compareTo(a.modifiedAt);
      });

      if (mounted) {
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải ghi chú: $e')),
        );
      }
    }
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _loadNotes();
  }

  void _onFilter(int? priority) {
    setState(() => _filterPriority = priority);
    _loadNotes();
  }

  void _onSort(String? sortBy) {
    setState(() => _sortBy = sortBy ?? 'modifiedAt');
    _loadNotes();
  }

  void _toggleViewMode() {
    setState(() => _isGrid = !_isGrid);
  }

  Future<void> _navigateToForm({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormScreen(note: note),
      ),
    );

    if (result == true && mounted) {
      _loadNotes();
    }
  }

  Future<void> _navigateToDetail(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(note: note),
      ),
    );
    if (mounted) {
      _loadNotes();
    }
  }

  Future<void> _deleteNote(int id) async {
    try {
      await db.deleteNote(id);
      _loadNotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadNotes,
          ),
          PopupMenuButton<int?>(
            onSelected: _onFilter,
            icon: const Icon(Icons.filter_list),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Tất cả')),
              const PopupMenuItem(value: 1, child: Text('Ưu tiên thấp')),
              const PopupMenuItem(value: 2, child: Text('Ưu tiên trung bình')),
              const PopupMenuItem(value: 3, child: Text('Ưu tiên cao')),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: _onSort,
            icon: const Icon(Icons.sort),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'modifiedAt', child: Text('Sắp xếp theo thời gian')),
              const PopupMenuItem(value: 'priority', child: Text('Sắp xếp theo ưu tiên')),
            ],
          ),
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: _onSearch,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text("Không có ghi chú"))
          : Padding(
        padding: const EdgeInsets.all(8),
        child: _isGrid
            ? GridView.builder(
          itemCount: _notes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, index) => NoteItem(
            note: _notes[index],
            onTap: () => _navigateToDetail(_notes[index]),
            onDelete: () => _deleteNote(_notes[index].id!),
          ),
        )
            : ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (_, index) => NoteItem(
            note: _notes[index],
            onTap: () => _navigateToDetail(_notes[index]),
            onDelete: () => _deleteNote(_notes[index].id!),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}