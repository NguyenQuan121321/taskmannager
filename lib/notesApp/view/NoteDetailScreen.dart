import 'package:flutter/material.dart';
import '../model/Note.dart';
import 'NoteForm.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteFormScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ưu tiên: ${note.priority == 1 ? 'Thấp' : note.priority == 2 ? 'Trung bình' : 'Cao'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Tạo: ${note.createdAt.toString().substring(0, 16)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Cập nhật: ${note.modifiedAt.toString().substring(0, 16)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nội dung:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                const Text(
                  'Nhãn:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: note.tags!.map((tag) => Chip(
                    label: Text(tag),
                  )).toList(),
                ),
              ],
              if (note.color != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Màu sắc:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 50,
                  color: Color(int.parse('0xFF${note.color!.replaceAll('#', '')}')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}