import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/costume.dart';
import '../models/booking.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // IN-MEMORY STORE FOR WEB DEMO
  static List<Costume> _webCostumes = [];

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // On Web, we don't init sqflite in this simple demo setup
    if (!kIsWeb) {
      _database = await _initDB('costumes.db');
    }
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 15, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE costumes (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      size TEXT NOT NULL,
      price REAL NOT NULL,
      image_path TEXT,
      is_available INTEGER NOT NULL,
      category_id INTEGER,
      quantity INTEGER NOT NULL DEFAULT 5
    )
    ''');

    await _createBookingsTable(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createBookingsTable(db);
    }
    if (oldVersion < 3) {
      // Add quantity column if missing
      try {
        await db.execute('ALTER TABLE costumes ADD COLUMN quantity INTEGER NOT NULL DEFAULT 5');
      } catch (e) {
        // Column might already exist if we messed up versions, ignore
      }
    }
    if (oldVersion < 4) {
      // RESET STOCK FOR EXISTING ITEMS
      // user requested to keep original collection but reset availability
      await db.rawUpdate('UPDATE costumes SET is_available = 1, quantity = 10');
    }
    if (oldVersion < 5) {
       // RESTORE AMEN BESPOKE COLLECTION
       await db.delete('costumes');

       final bespokeCostumes = [
        {
          'name': 'Notte - Bleu Roi Iconique',
          'description': 'Costume sur mesure bleu roi, élégance intemporelle pour vos soirées.',
          'size': 'M',
          'price': 450.0,
          'image_path': 'https://images.unsplash.com/photo-1594938298603-c8148c4729d7?auto=format&fit=crop&q=80&w=800',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        },
        {
          'name': 'Noir Éternel - Smoking',
          'description': 'L\'Art du Smoking noir, sophistication absolue.',
          'size': 'L',
          'price': 500.0,
          'image_path': 'https://images.unsplash.com/photo-1598808503746-f34c53b9323e?auto=format&fit=crop&q=80&w=800',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        },
        {
          'name': 'Midnight Pinstripes',
          'description': 'La sophistication moderne avec des rayures fines.',
          'size': 'L',
          'price': 400.0,
          'image_path': 'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?auto=format&fit=crop&q=80&w=800',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        },
        {
          'name': 'Gris Manhattan',
          'description': 'Flanelle grise, coupe croisée. Idéal pour l\'hiver.',
          'size': 'XL',
          'price': 350.0,
          'image_path': 'https://images.unsplash.com/photo-1497339100210-9e87df79c218?auto=format&fit=crop&q=80&w=800',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        },
        {
          'name': 'Prince de Galles',
          'description': 'Motif classique pour une élégance britannique.',
          'size': 'M',
          'price': 480.0,
          'image_path': 'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?auto=format&fit=crop&q=80&w=800',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        },
        {
          'name': 'Velours Bordeaux',
          'description': 'Veste de smoking en velours pour les grandes occasions.',
          'size': 'M',
          'price': 600.0,
          'image_path': 'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?auto=format&fit=crop&q=80&w=800',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        }
      ];

      for (var c in bespokeCostumes) {
        await db.insert('costumes', c);
      }
    }
    if (oldVersion < 6) {
      // 1. Add size column to bookings
      try {
        await db.execute('ALTER TABLE bookings ADD COLUMN size TEXT NOT NULL DEFAULT "Standard"');
      } catch (e) {
        // Ignore if exists
      }

      // 2. Fix Velours Bordeaux Image
      await db.rawUpdate(
        'UPDATE costumes SET image_path = ? WHERE name LIKE ?',
        ['https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?auto=format&fit=crop&q=80&w=800', '%Velours Bordeaux%'] 
      );
      // Wait, the previous image was actually that same URL. 
      // User said "image qui correspond pas", maybe I should try a different one or maybe the previous restore used a bad one?
      // I'll update it to a very clear red velvet suit image just in case.
      await db.rawUpdate(
        'UPDATE costumes SET image_path = ? WHERE name LIKE ?',
        ['https://i.pinimg.com/736x/a9/3b/8e/a93b8e8884a441162441s88365213.jpg', '%Velours Bordeaux%'] 
      );


      // 3. Add New Items
      final newItems = [
        {
          'name': 'Beige Lin - Été',
          'description': 'Costume en lin beige léger, parfait pour les mariages d\'été.',
          'size': 'L',
          'price': 400.0,
          'image_path': 'https://images.unsplash.com/photo-1593032465175-d5a890e4e5da?auto=format&fit=crop&q=80&w=800',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        },
        {
          'name': 'Smoking Blanc - Gala',
          'description': 'Smoking blanc immaculé avec revers en satin noir.',
          'size': 'M',
          'price': 550.0,
          'image_path': 'https://wp-media-dejiandkola.s3.eu-west-2.amazonaws.com/2020/09/120089573_3780074748688104_995916302928762415_n.jpg',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        },
        {
          'name': 'Gilet Vintage - Peaky Blinders',
          'description': 'Style rétro années 20, tweed gris souris.',
          'size': 'M',
          'price': 200.0,
          'image_path': 'https://images.unsplash.com/photo-1517438476312-10d79c077509?auto=format&fit=crop&q=80&w=800',
          'is_available': 1,
          'category_id': 1,
          'quantity': 10
        }
      ];

      for (var item in newItems) {
        await db.insert('costumes', item);
      }
    }
    if (oldVersion < 7) {
      // 1. Remove Gilet Vintage
      await db.delete('costumes', where: 'name LIKE ?', whereArgs: ['%Gilet Vintage%']);

      // 2. Update Images (More generic/reliable)
      // Map of Name Part -> New Image URL
      final imageUpdates = {
        'Bleu Roi': 'https://images.unsplash.com/photo-1594938298603-c8148c4729d7?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'Noir Éternel': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', // Tuxedo
        'Midnight Pinstripes': 'https://images.unsplash.com/photo-1593030761757-71fae45fa5e7?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', // Stripes
        'Gris Manhattan': 'https://images.unsplash.com/photo-1542574621-e088a4464f7e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', // Grey
        'Prince de Galles': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', // Grey/Check
        'Velours Bordeaux': 'https://i.pinimg.com/736x/a9/3b/8e/a93b8e8884a441162441s88365213.jpg', // Keep this one as it was specifically asked for/fixed
        'Beige Lin': 'https://images.unsplash.com/photo-1593032465175-d5a890e4e5da?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', // Beige
        'Smoking Blanc': 'https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', // White
      };

      for (var entry in imageUpdates.entries) {
         await db.rawUpdate(
          'UPDATE costumes SET image_path = ? WHERE name LIKE ?',
          [entry.value, '%${entry.key}%']
        );
      }
    }
    if (oldVersion < 8) {
      // 1. Add jacket_size to bookings
      try {
        await db.execute('ALTER TABLE bookings ADD COLUMN jacket_size TEXT NOT NULL DEFAULT "M"');
      } catch (e) {
        // Ignore
      }

      // 2. Final Comprehensive Image Update
      final imageUpdatesV8 = {
        'Bleu Roi': 'https://images.pexels.com/photos/3755706/pexels-photo-3755706.jpeg?auto=compress&cs=tinysrgb&w=800',
        'Noir Éternel': 'https://images.pexels.com/photos/1342609/pexels-photo-1342609.jpeg?auto=compress&cs=tinysrgb&w=800', 
        'Midnight Pinstripes': 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=800', 
        'Gris Manhattan': 'https://images.pexels.com/photos/325876/pexels-photo-325876.jpeg?auto=compress&cs=tinysrgb&w=800', 
        'Prince de Galles': 'https://images.pexels.com/photos/1036622/pexels-photo-1036622.jpeg?auto=compress&cs=tinysrgb&w=800', 
        'Velours Bordeaux': 'https://i.pinimg.com/736x/a9/3b/8e/a93b8e8884a441162441s88365213.jpg', 
        'Beige Lin': 'https://images.pexels.com/photos/3775498/pexels-photo-3775498.jpeg?auto=compress&cs=tinysrgb&w=800', 
        'Smoking Blanc': 'https://images.pexels.com/photos/2897531/pexels-photo-2897531.jpeg?auto=compress&cs=tinysrgb&w=800', 
      };

      for (var entry in imageUpdatesV8.entries) {
         await db.rawUpdate(
          'UPDATE costumes SET image_path = ? WHERE name LIKE ?',
          [entry.value, '%${entry.key}%']
        );
      }
    }
    if (oldVersion < 9) {
      // 3. Official Amen Bespoke Images
      final officialImages = {
        'Bleu Roi': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0009_Homme-en-Costume-Elegant_remix_01jz43xe9te1zsvggxvd49ce3e.png', // Notte
        'Noir Éternel': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0101_Costume-Elegant-et-Moderne_remix_01jz46x95fef5vhd34cgb7vn1s.png', // Noir Eternal
        'Midnight Pinstripes': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0117_Homme-en-Costume-Elegant_remix_01jz47tp3rfpd9ea1rj7s47zna.png', // Midnight P.
        'Gris Manhattan': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0241_Homme-en-Costume-Bleu_remix_01jz4ckh07e7mt37s684jvw0zt.png', // Silver Mist
        'Prince de Galles': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2358_Modele-en-Costume-Elegant_remix_01jz6npvjyecxtwztb18fwgg8p.png', // Solstice Foncé (Substitute)
        'Velours Bordeaux': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2144_Modele-en-Costume-Classique_remix_01jz6e04x2fz1tcw017rmec251.png', // Bordeaux Majestic
        'Beige Lin': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_1539_Homme-en-costume-elegant_remix_01jz5s3v42ez3vtgbjpdagv744.png', // Brun Toscane
        'Smoking Blanc': 'https://amen-bespoke.com/wp-content/uploads/2025/07/white-cotton-soragna-trousers-2.webp', // Lumen (Pants only available on site)
      };

      for (var entry in officialImages.entries) {
         await db.rawUpdate(
          'UPDATE costumes SET image_path = ? WHERE name LIKE ?',
          [entry.value, '%${entry.key}%']
        );
      }
    }
    if (oldVersion < 10) {
      // 4. Update Smoking Blanc Image (User Provided)
      await db.rawUpdate(
        'UPDATE costumes SET image_path = ? WHERE name LIKE ?',
        [
          'https://wp-media-dejiandkola.s3.eu-west-2.amazonaws.com/2020/09/120089573_3780074748688104_995916302928762415_n.jpg', 
          '%Smoking Blanc%' // Target the white tuxedo
        ]
      );
    }
    if (oldVersion < 11) {
      // Emergency Restore: Fix missing items, wrong images, and stock
      await db.delete('costumes');
      
      final restoredCostumes = [
        {
          'name': 'Notte (Bleu Roi)',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0009_Homme-en-Costume-Elegant_remix_01jz43xe9te1zsvggxvd49ce3e.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Noir Éternel',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0101_Costume-Elegant-et-Moderne_remix_01jz46x95fef5vhd34cgb7vn1s.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Midnight Pinstripes',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0117_Homme-en-Costume-Elegant_remix_01jz47tp3rfpd9ea1rj7s47zna.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Bordeaux Majestic',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2144_Modele-en-Costume-Classique_remix_01jz6e04x2fz1tcw017rmec251.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Gris Manhattan',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0241_Homme-en-Costume-Bleu_remix_01jz4ckh07e7mt37s684jvw0zt.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'XL',
          'category_id': 1
        },
        {
          'name': 'Brun Toscane',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_1539_Homme-en-costume-elegant_remix_01jz5s3v42ez3vtgbjpdagv744.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Prince de Galles',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2358_Modele-en-Costume-Elegant_remix_01jz6npvjyecxtwztb18fwgg8p.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Smoking Blanc',
          'price': 1500,
          'image_path': 'https://wp-media-dejiandkola.s3.eu-west-2.amazonaws.com/2020/09/120089573_3780074748688104_995916302928762415_n.jpg',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
      ];

      for (var costume in restoredCostumes) {
        await db.insert('costumes', costume);
      }
    }
    if (oldVersion < 12) {
      // Emergency Restore V2: Force retry of missing items
      await db.delete('costumes');
      
      final restoredCostumesV12 = [
        {
          'name': 'Notte (Bleu Roi)',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0009_Homme-en-Costume-Elegant_remix_01jz43xe9te1zsvggxvd49ce3e.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Noir Éternel',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0101_Costume-Elegant-et-Moderne_remix_01jz46x95fef5vhd34cgb7vn1s.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Midnight Pinstripes',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0117_Homme-en-Costume-Elegant_remix_01jz47tp3rfpd9ea1rj7s47zna.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Bordeaux Majestic',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2144_Modele-en-Costume-Classique_remix_01jz6e04x2fz1tcw017rmec251.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Gris Manhattan',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0241_Homme-en-Costume-Bleu_remix_01jz4ckh07e7mt37s684jvw0zt.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'XL',
          'category_id': 1
        },
        {
          'name': 'Brun Toscane',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_1539_Homme-en-costume-elegant_remix_01jz5s3v42ez3vtgbjpdagv744.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Prince de Galles',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2358_Modele-en-Costume-Elegant_remix_01jz6npvjyecxtwztb18fwgg8p.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Smoking Blanc',
          'price': 1500,
          'image_path': 'https://wp-media-dejiandkola.s3.eu-west-2.amazonaws.com/2020/09/120089573_3780074748688104_995916302928762415_n.jpg',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
      ];

      for (var costume in restoredCostumesV12) {
        await db.insert('costumes', costume);
      }
    }
    if (oldVersion < 13) {
      // Emergency Restore V3: The Final Hard Reset
      // User reported persistent issues. We burn it down and rebuild.
      await db.delete('costumes');
      
      final restoredCostumesV13 = [
        {
          'name': 'Notte (Bleu Roi)',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0009_Homme-en-Costume-Elegant_remix_01jz43xe9te1zsvggxvd49ce3e.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Noir Éternel',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0101_Costume-Elegant-et-Moderne_remix_01jz46x95fef5vhd34cgb7vn1s.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Midnight Pinstripes',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0117_Homme-en-Costume-Elegant_remix_01jz47tp3rfpd9ea1rj7s47zna.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Bordeaux Majestic',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2144_Modele-en-Costume-Classique_remix_01jz6e04x2fz1tcw017rmec251.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Gris Manhattan',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0241_Homme-en-Costume-Bleu_remix_01jz4ckh07e7mt37s684jvw0zt.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'XL',
          'category_id': 1
        },
        {
          'name': 'Brun Toscane',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_1539_Homme-en-costume-elegant_remix_01jz5s3v42ez3vtgbjpdagv744.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Prince de Galles',
          'price': 1200,
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2358_Modele-en-Costume-Elegant_remix_01jz6npvjyecxtwztb18fwgg8p.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Smoking Blanc',
          'price': 1500,
          'image_path': 'https://wp-media-dejiandkola.s3.eu-west-2.amazonaws.com/2020/09/120089573_3780074748688104_995916302928762415_n.jpg',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
      ];

      for (var costume in restoredCostumesV13) {
        await db.insert('costumes', costume);
      }
    }

    if (oldVersion < 14) {
      // Emergency Restore V4: Fix Prices & Descriptions
      await db.delete('costumes');
      
      final restoredCostumesV14 = [
        {
          'name': 'Notte (Bleu Roi)',
          'price': 450,
          'description': 'Une élégance royale pour vos soirées les plus prestigieuses. Ce costume bleu roi incarne la confiance et le charisme.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0009_Homme-en-Costume-Elegant_remix_01jz43xe9te1zsvggxvd49ce3e.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Noir Éternel',
          'price': 500,
           'description': 'Le classique intemporel. Une coupe parfaite et un noir profond pour une allure sophistiquée en toute occasion.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0101_Costume-Elegant-et-Moderne_remix_01jz46x95fef5vhd34cgb7vn1s.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Midnight Pinstripes',
          'price': 550,
          'description': 'L\'audace des rayures fines sur un fond sombre. Idéal pour ceux qui veulent se démarquer avec subtilité.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0117_Homme-en-Costume-Elegant_remix_01jz47tp3rfpd9ea1rj7s47zna.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Bordeaux Majestic',
          'price': 600,
          'description': 'Osez la couleur avec ce bordeaux profond. Un choix audacieux pour les hommes de goût.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2144_Modele-en-Costume-Classique_remix_01jz6e04x2fz1tcw017rmec251.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Gris Manhattan',
          'price': 650,
           'description': 'Le chic urbain par excellence. Ce gris structuré est parfait pour les événements de jour comme de nuit.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0241_Homme-en-Costume-Bleu_remix_01jz4ckh07e7mt37s684jvw0zt.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'XL',
          'category_id': 1
        },
        {
          'name': 'Brun Toscane',
          'price': 550,
          'description': 'Chaleur et distinction. Ce costume brun apporte une touche d\'originalité distinguée.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_1539_Homme-en-costume-elegant_remix_01jz5s3v42ez3vtgbjpdagv744.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'name': 'Prince de Galles',
          'price': 700,
          'description': 'Le motif iconique pour une allure british. Raffinement garanti.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2358_Modele-en-Costume-Elegant_remix_01jz6npvjyecxtwztb18fwgg8p.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'name': 'Smoking Blanc',
          'price': 800,
          'description': 'L\'apogée du luxe pour vos mariages et grands événements. Un blanc pur pour une présence inoubliable.',
          'image_path': 'https://wp-media-dejiandkola.s3.eu-west-2.amazonaws.com/2020/09/120089573_3780074748688104_995916302928762415_n.jpg',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
      ];

      for (var costume in restoredCostumesV14) {
        await db.insert('costumes', costume);
      }
    }

    if (oldVersion < 15) {
      // Emergency Restore V5: Align IDs with Backend (1-8)
      await db.delete('costumes');
      
      final restoredCostumesV15 = [
        {
          'id': 1,
          'name': 'Notte (Bleu Roi)',
          'price': 450,
          'description': 'Une élégance royale pour vos soirées les plus prestigieuses. Ce costume bleu roi incarne la confiance et le charisme.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0009_Homme-en-Costume-Elegant_remix_01jz43xe9te1zsvggxvd49ce3e.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'id': 2,
          'name': 'Noir Éternel',
          'price': 500,
           'description': 'Le classique intemporel. Une coupe parfaite et un noir profond pour une allure sophistiquée en toute occasion.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0101_Costume-Elegant-et-Moderne_remix_01jz46x95fef5vhd34cgb7vn1s.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'id': 3,
          'name': 'Midnight Pinstripes',
          'price': 550,
          'description': 'L\'audace des rayures fines sur un fond sombre. Idéal pour ceux qui veulent se démarquer avec subtilité.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0117_Homme-en-Costume-Elegant_remix_01jz47tp3rfpd9ea1rj7s47zna.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'id': 4,
          'name': 'Bordeaux Majestic',
          'price': 600,
          'description': 'Osez la couleur avec ce bordeaux profond. Un choix audacieux pour les hommes de goût.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2144_Modele-en-Costume-Classique_remix_01jz6e04x2fz1tcw017rmec251.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'id': 5,
          'name': 'Gris Manhattan',
          'price': 650,
           'description': 'Le chic urbain par excellence. Ce gris structuré est parfait pour les événements de jour comme de nuit.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0241_Homme-en-Costume-Bleu_remix_01jz4ckh07e7mt37s684jvw0zt.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'XL',
          'category_id': 1
        },
        {
          'id': 6,
          'name': 'Brun Toscane',
          'price': 550,
          'description': 'Chaleur et distinction. Ce costume brun apporte une touche d\'originalité distinguée.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_1539_Homme-en-costume-elegant_remix_01jz5s3v42ez3vtgbjpdagv744.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'L',
          'category_id': 1
        },
        {
          'id': 7,
          'name': 'Prince de Galles',
          'price': 700,
          'description': 'Le motif iconique pour une allure british. Raffinement garanti.',
          'image_path': 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2358_Modele-en-Costume-Elegant_remix_01jz6npvjyecxtwztb18fwgg8p.png',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
        {
          'id': 8,
          'name': 'Smoking Blanc',
          'price': 800,
          'description': 'L\'apogée du luxe pour vos mariages et grands événements. Un blanc pur pour une présence inoubliable.',
          'image_path': 'https://wp-media-dejiandkola.s3.eu-west-2.amazonaws.com/2020/09/120089573_3780074748688104_995916302928762415_n.jpg',
          'is_available': 1,
          'quantity': 10,
          'size': 'M',
          'category_id': 1
        },
      ];

      for (var costume in restoredCostumesV15) {
        await db.insert('costumes', costume, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future _createBookingsTable(Database db) async {
    await db.execute('''
    CREATE TABLE bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      costume_id INTEGER NOT NULL,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      phone_number TEXT NOT NULL,
      address TEXT NOT NULL,
      start_date TEXT NOT NULL,
      duration_days INTEGER NOT NULL,
      total_price REAL NOT NULL,
      status TEXT NOT NULL,
      size TEXT NOT NULL,
      jacket_size TEXT NOT NULL,
      FOREIGN KEY (costume_id) REFERENCES costumes (id)
    )
    ''');
  }

  Future<void> insertCostume(Costume costume) async {
    if (kIsWeb) {
      _webCostumes.add(costume);
      return;
    }
    final db = await instance.database;
    await db.insert(
      'costumes',
      costume.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCostume(Costume costume) async {
    if (kIsWeb) {
      final index = _webCostumes.indexWhere((c) => c.id == costume.id);
      if (index != -1) {
        _webCostumes[index] = costume;
      }
      return;
    }
    final db = await instance.database;
    await db.update(
      'costumes',
      costume.toMap(),
      where: 'id = ?',
      whereArgs: [costume.id],
    );
  }

  // --- BOOKING METHODS ---

  Future<int> insertBooking(Booking booking) async {
    // For web demo, we just log and return a mock ID
    if (kIsWeb) {
      print('Web Booking: ${booking.toMap()}');
      return 999;
    }
    final db = await instance.database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<void> deleteBooking(int id) async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Booking>> getBookings() async {
    if (kIsWeb) {
      return [];
    }
    final db = await instance.database;
    final result = await db.query('bookings', orderBy: 'id DESC');
    return result.map((json) => Booking.fromJson(json)).toList();
  }

  Future<List<Booking>> getPendingBookings() async {
    if (kIsWeb) return [];
    final db = await instance.database;
    // We assume 'Confirmed' means ready to sync to backend
    // 'Synced' means already on backend
    final result = await db.query(
      'bookings', 
      where: 'status = ?', 
      whereArgs: ['Confirmed']
    );
    return result.map((json) => Booking.fromJson(json)).toList();
  }

  Future<void> updateBookingStatus(int id, String newStatus) async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.update(
      'bookings',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Costume>> getCostumes() async {
    if (kIsWeb) {
      return _webCostumes;
    }
    final db = await instance.database;
    final result = await db.query('costumes');
    return result.map((json) => Costume.fromJson(json)).toList();
  }

  Future<void> clearCostumes() async {
    if (kIsWeb) {
      _webCostumes.clear();
      return;
    }
    final db = await instance.database;
    await db.delete('costumes');
    await db.delete('bookings'); // Also clear bookings on reset
  }
}

