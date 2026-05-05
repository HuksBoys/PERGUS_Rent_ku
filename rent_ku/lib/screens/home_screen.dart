import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/barang_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../widgets/skeleton_loader.dart';
import 'detail_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;
  const HomeScreen({super.key, this.showAppBar = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BarangProvider>().fetchItems());
  }

  @override
  Widget build(BuildContext context) {
    final barangProvider = context.watch<BarangProvider>();
    // ignore: unused_local_variable
    final auth = context.read<AuthProvider>();

    if (!widget.showAppBar) {
      return _buildBody(barangProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('RentKU Katalog',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(context.watch<ThemeProvider>().isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      body: _buildBody(barangProvider),
    );
  }

  Widget _buildBody(BarangProvider barangProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [Colors.black, Colors.grey.shade900]
              : [Colors.white, Colors.blue.shade50.withOpacity(0.5)],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () => barangProvider.fetchItems(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  children: [
                    const TextSpan(text: 'Sewa Alat\n'),
                    TextSpan(
                      text: 'Elektronik Terbaik',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: barangProvider.isLoading
                    ? SkeletonLoader.productGrid()
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 120, top: 10),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: barangProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = barangProvider.items[index];
                          final itemIsDark =
                              Theme.of(context).brightness == Brightness.dark;

                          return InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(barang: item))),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    itemIsDark ? Colors.grey.shade900 : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent
                                        .withOpacity(itemIsDark ? 0.05 : 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            color: itemIsDark
                                                ? Colors.black26
                                                : Colors.grey.shade100,
                                            child: item.gambarUrl != null
                                                ? Hero(
                                                    tag: 'barang_${item.id}',
                                                    child: Image.network(
                                                        item.gambarUrl!,
                                                        fit: BoxFit.cover),
                                                  )
                                                : const Icon(Icons.image,
                                                    size: 50, color: Colors.grey),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: itemIsDark
                                                ? Colors.white.withOpacity(0.05)
                                                : Colors.blue.shade50
                                                    .withOpacity(0.3),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.namaBarang,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .inventory_2_outlined,
                                                      size: 12,
                                                      color:
                                                          Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text('Stok: ${item.stok}',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey.shade600)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Price Badge Melayang
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blueAccent
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          NumberFormat.compactCurrency(
                                                  locale: 'id', symbol: 'Rp ')
                                              .format(item.hargaSewa),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Kategori Badge di pojok kiri bawah gambar
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item.kategori,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
