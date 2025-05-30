import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pokemon_list_vm.dart';
import '../utils/generation_utils.dart';
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cerca Pokémon…',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: vm.search,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        DropdownButton<int?>(
                          value: vm.selectedGeneration,
                          hint: const Text('Generació'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Totes')),
                            ...generationLabels.entries.map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            ),
                          ],
                          onChanged: (g) => vm.setGeneration(g),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String?>(
                          value: vm.selectedType,
                          hint: const Text('Tipus'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Tots')),
                            ...allTypes.map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.toUpperCase()),
                              ),
                            ),
                          ],
                          onChanged: (t) => vm.setType(t),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (vm.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )

          else if (vm.pokemons.isEmpty && !vm.loading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: const Center(
                child: Text(
                  'No s\'ha trobat cap Pokémon amb aquest nom.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )

          else
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => PokemonCard(pokemon: vm.pokemons[i]),
                  childCount: vm.pokemons.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .8,
                ),
              ),
            ),

          if (vm.loading && vm.error == null)
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
