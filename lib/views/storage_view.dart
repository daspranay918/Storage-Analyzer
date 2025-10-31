import 'package:flutter/material.dart';
import 'package:storage_analyzer/models/file_category_model.dart';
import 'package:storage_analyzer/presenters/storage_presenter.dart';

class StorageView extends StatefulWidget {
  const StorageView({super.key});

  @override
  State<StorageView> createState() => _StorageViewState();
}

class _StorageViewState extends State<StorageView> {
  final StoragePresenter _presenter = StoragePresenter();
  List<FileCategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  Future<void> _loadStorageData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final granted = await _presenter.requestPermission();
    if (!granted) {
      setState(() {
        _isLoading = false;
        _error = 'Permission denied. Please grant storage access.';
      });
      return;
    }

    try {
      final data = await _presenter.analyzeStorage();
      setState(() {
        _categories = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Analyzer'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Text(_error, style: const TextStyle(color: Colors.red)),
            )
          : _categories.isEmpty
          ? const Center(child: Text('No data found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final item = _categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      _getIcon(item.name),
                      color: Colors.teal,
                      size: 32,
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      item.name.contains('Documents')
                          ? 'Cannot access documents (Android 13+)'
                          : '${item.count} files',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      item.formattedSize,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStorageData,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  IconData _getIcon(String category) {
    if (category.contains('Image')) return Icons.image;
    if (category.contains('Video')) return Icons.video_library;
    if (category.contains('Audio')) return Icons.music_note;
    if (category.contains('Document')) return Icons.description;
    return Icons.insert_drive_file;
  }
}
