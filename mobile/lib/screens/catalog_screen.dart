import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../models/costume.dart';
import '../services/theme_service.dart';
import 'detail_screen.dart';
import 'bookings_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Costume>> _costumesFuture;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _refreshCostumes();
  }

  void _refreshCostumes() {
    setState(() {
      _costumesFuture = DatabaseHelper.instance.getCostumes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<SyncService>(context);
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeynar', style: TextStyle(color: Color(0xFF800020), fontWeight: FontWeight.bold)),
        centerTitle: true,
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: themeService.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () {
                themeService.toggleTheme();
              },
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Data',
            onPressed: () async {
              await syncService.syncData();
              _refreshCostumes();
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.grey), // Admin button (Changed from white to be visible)
            tooltip: 'View Bookings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            width: double.infinity,
            color: Colors.deepPurple.shade50,
            child: Column(
              children: [
                Text(
                  'Discover The Collection',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF800020),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Le style c'est l'homme",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF800020),
                  ),
                ),
              ],
            ),
          ),
          
          if (syncService.isSyncing) const LinearProgressIndicator(),
          Expanded(
            child: FutureBuilder<List<Costume>>(
              future: _costumesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No costumes found. Try syncing.'),
                  );
                }

                final costumes = snapshot.data!;
                
                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // Adjust item height
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: costumes.length,
                    itemBuilder: (context, index) {
                      return _buildCostumeCard(costumes[index], isGrid: true);
                    },
                  );
                } else {
                  return ListView.builder(
                    itemCount: costumes.length,
                    itemBuilder: (context, index) {
                      return _buildCostumeCard(costumes[index], isGrid: false);
                    },
                  );
                }
              },
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Center(
              child: Text(
                'Copyright 2025 Ouyhia & Ouarhezi',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostumeCard(Costume costume, {required bool isGrid}) {
    if (isGrid) {
      return GestureDetector(
        onTap: () => _navigateToDetail(costume),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: (costume.imagePath != null && costume.imagePath!.startsWith('http'))
                    ? Image.network(
                        costume.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      costume.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${costume.price.toStringAsFixed(0)} MAD',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: (costume.imagePath != null && costume.imagePath!.startsWith('http'))
                ? Image.network(
                    costume.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image),
                  )
                : const Icon(Icons.image),
          ),
          title: Text(costume.name),
          subtitle: Text('${costume.price.toStringAsFixed(0)} MAD / jour'),
          trailing: costume.isAvailable
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.cancel, color: Colors.red),
          onTap: () => _navigateToDetail(costume),
        ),
      );
    }
  }

  void _navigateToDetail(Costume costume) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(costume: costume),
      ),
    );
  }
}
