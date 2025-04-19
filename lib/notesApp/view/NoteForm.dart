import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../model/Note.dart';
import '../db/NoteDatabaseHelper.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  int _priority = 1;
  List<String> _tags = [];
  Color _selectedColor = Colors.white;
  String? _colorHex;

  final NoteDatabaseHelper db = NoteDatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
      _tags = widget.note!.tags ?? [];
      if (widget.note!.color != null) {
        _selectedColor = Color(int.parse('0xFF${widget.note!.color!.replaceAll('#', '')}'));
        _colorHex = widget.note!.color;
      }
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      try {
        final note = Note(
          id: widget.note?.id,
          title: _titleController.text,
          content: _contentController.text,
          priority: _priority,
          createdAt: widget.note?.createdAt ?? DateTime.now(),
          modifiedAt: DateTime.now(),
          tags: _tags.isNotEmpty ? _tags : null,
          color: _colorHex,
        );

        if (widget.note == null) {
          await db.insertNote(note);
        } else {
          await db.updateNote(note);
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu ghi chú: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm ghi chú' : 'Sửa ghi chú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Nội dung'),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Mức độ ưu tiên:'),
                DropdownButton<int>(
                  value: _priority,
                  onChanged: (value) {
                    setState(() => _priority = value!);
                  },
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Thấp')),
                    DropdownMenuItem(value: 2, child: Text('Trung bình')),
                    DropdownMenuItem(value: 3, child: Text('Cao')),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Chọn màu sắc:'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Chọn màu'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) {
                              setState(() {
                                _selectedColor = color;
                                _colorHex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                              });
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Chọn màu'),
                ),
                const SizedBox(height: 16),
                const Text('Nhãn:'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(labelText: 'Thêm nhãn'),
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addTag,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _tags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: Text(widget.note == null ? 'Thêm' : 'Cập nhật'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}