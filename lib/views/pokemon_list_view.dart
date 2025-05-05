import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pokemon_list_vm.dart';
import '../widgets/pokemon_card.dart';

class PokemonListView extends StatelessWidget {
  const PokemonListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PokemonListVM>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Pokédex'),
            bottom: AppBar(
              toolbarHeight: 56,
              title: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cerca Pokémon…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: vm.search,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  // carrega la següent pàgina quan arribem al final
                  if (i == vm.pokemons.length - 1) vm.loadMore();
                  return PokemonCard(pokemon: vm.pokemons[i]);
                },
                childCount: vm.pokemons.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: .8,
              ),
            ),
          ),
          if (vm.loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
