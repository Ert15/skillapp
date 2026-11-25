import 'package:flutter/material.dart';
import '../demo_store.dart';
import '../widgets/offer_card.dart';

class FavoritesScreen extends StatelessWidget {
  final DemoStore store;

  const FavoritesScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Избранное',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final favorites = store.favorites;
            if (favorites.isEmpty) {
              return const Center(
                child: Text('Нажми ♥ на карточке, чтобы добавить её сюда'),
              );
            }
            return ListView(
              children: [
                for (final offer in favorites)
                  OfferCard(
                    id: offer.id,
                    data: offer.toMap(),
                    store: store,
                  ),
              ],
            );
          },
        ),
      );
}
