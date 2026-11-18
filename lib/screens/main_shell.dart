import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chats_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'create_offer_screen.dart';
import '../app_mode.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;
  final _pages = const [
    HomeScreen(),
    ChatsScreen(),
    FavoritesScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _i, children: _pages),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFEB5A3D),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () async {
            if (previewMode) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Публикация доступна после подключения Firebase')));
              return;
            }
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateOfferScreen()),
            );
          },
          child: const Icon(Icons.add, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          elevation: 8,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_outlined, 'Feed'),
                _navItem(1, Icons.search_outlined, 'Requests'),
                const SizedBox(width: 52),
                _navItem(2, Icons.favorite_border, 'Favorites'),
                _navItem(3, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      );

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _i == index;
    final color = selected ? const Color(0xFF5B55D6) : Colors.grey.shade600;
    return InkWell(
      onTap: () => setState(() => _i = index),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}
