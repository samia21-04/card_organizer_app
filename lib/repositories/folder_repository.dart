import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/folder.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return db.insert('folders', folder.toMap());
  }

  Future<List<Folder>> getAllFolders() async {
    final db = await _dbHelper.database;
    final maps = await db.query('folders', orderBy: 'folder_name ASC');
    return maps.map((m) => Folder.fromMap(m)).toList();
  }

  Future<Folder?> getFolderById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('folders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Folder.fromMap(maps.first);
  }

  Future<int> updateFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await _dbHelper.database;
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getFolderCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM folders');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}