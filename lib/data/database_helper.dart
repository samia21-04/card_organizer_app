import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // required for FK + CASCADE to work
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
        await _prepopulate(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL UNIQUE,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _prepopulate(Database db) async {
    // choose 2-4 suits here:
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    final selectedSuits = suits; // suits.take(2).toList() for 2 suits, etc.

    final now = DateTime.now().toIso8601String();

    // insert folders first
    final folderIds = <String, int>{};
    for (final suit in selectedSuits) {
      final id = await db.insert('folders', {
        'folder_name': suit,
        'timestamp': now,
      });
      folderIds[suit] = id;
    }

    // ranks 13
    final ranks = [
      'Ace','2','3','4','5','6','7','8','9','10','Jack','Queen','King'
    ];

    // insert cards
    for (final suit in selectedSuits) {
      for (final rank in ranks) {
        await db.insert('cards', {
          'card_name': rank,
          'suit': suit,
          'image_url': _assetPathFor(suit, rank), // or a network url
          'folder_id': folderIds[suit],
        });
      }
    }
  }

  // assumes your assets are named like: AS.png, 10H.png, QD.png, KC.png
  String _assetPathFor(String suit, String rank) {
    final r = switch (rank) {
      'Ace' => 'A',
      'Jack' => 'J',
      'Queen' => 'Q',
      'King' => 'K',
      _ => rank,
    };

    final s = switch (suit) {
      'Spades' => 'S',
      'Hearts' => 'H',
      'Diamonds' => 'D',
      'Clubs' => 'C',
      _ => 'S',
    };

    return 'assets/cards/$r$s.png';
  }
}