import 'package:flutter/material.dart';
import '../demo_store.dart';
import 'home_screen.dart';
import 'chats_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'create_offer_screen.dart';

class MainShell extends StatefulWidget {
  final DemoStore store;
  final String profileName;
  final VoidCallback onSignOut;
  final ValueChanged<String> onNameChanged;

  const MainShell({
    super.key,
    required this.store,
    required this.profileName,
    required this.onSignOut,
    required this.onNameChanged,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _i,
          children: [
            HomeScreen(store: widget.store),
            ChatsScreen(store: widget.store),
            FavoritesScreen(store: widget.store),
            ProfileScreen(
              store: widget.store,
              profileName: widget.profileName,
              onSignOut: widget.onSignOut,
              onNameChanged: widget.onNameChanged,
              onOpenChats: () => setState(() => _i = 1),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFEB5A3D),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateOfferScreen(
                  store: widget.store,
                ),
              ),
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
