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
          // ──────────────────────────────────────────
          //  AppBar amb cercador i tres filtres
          // ──────────────────────────────────────────
          SliverAppBar(
            floating: true,
            title: const Text('Pokédex'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(140),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // ── Cercador per nom ────────────────────────
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cerca Pokémon…',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: vm.search,
                    ),
                    const SizedBox(height: 8),
                    // ── Filtres: Generació · Tipus · Evolució ──
                    Row(
                      children: [
                        // Generació
                        DropdownButton<int?>(
                          value: vm.selectedGeneration,
                          hint: const Text('Generació'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Totes')),
                            ...generationLabels.entries.map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            ),
                          ],
                          onChanged: (gen) => vm.setGeneration(gen),
                        ),
                        const SizedBox(width: 8),
                        // Tipus
                        DropdownButton<String?>(
                          value: vm.selectedType,
                          hint: const Text('Tipus'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Tots')),
                            ...allTypes.map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.toUpperCase()),
                              ),
                            ),
                          ],
                          onChanged: (type) => vm.setType(type),
                        ),
                        const SizedBox(width: 8),
                        // Etapa evolutiva
                        DropdownButton<EvoStage>(
                          value: vm.selectedStage,
                          items: EvoStage.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(evoStageLabels[s]!),
                                ),
                              )
                              .toList(),
                          onChanged: (stage) {
                            if (stage != null) vm.setStage(stage);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ──────────────────────────────────────────
          //  Graella de targetes de Pokémon
          // ──────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  // Paginació infinita (carrega la següent pàgina)
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

          // Loader a la part inferior
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
