import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/card.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return db.insert('cards', card.toMap());
  }

  Future<List<PlayingCard>> getAllCards() async {
    final db = await _dbHelper.database;
    final maps = await db.query('cards');
    return maps.map((m) => PlayingCard.fromMap(m)).toList();
  }

  Future<List<PlayingCard>> getCardsByFolderId(int folderId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'card_name ASC',
    );
    return maps.map((m) => PlayingCard.fromMap(m)).toList();
  }

  Future<PlayingCard?> getCardById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('cards', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return PlayingCard.fromMap(maps.first);
  }

  Future<int> updateCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCardCountByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE folder_id = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}