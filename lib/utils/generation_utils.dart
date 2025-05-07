import 'package:flutter/material.dart';

/// Rang d’ID → generació (Kanto, Johto, …)
int generationOfId(int id) {
  if (id <= 151) return 1;
  if (id <= 251) return 2;
  if (id <= 386) return 3;
  if (id <= 493) return 4;
  if (id <= 649) return 5;
  if (id <= 721) return 6;
  if (id <= 809) return 7;
  if (id <= 905) return 8;
  return 9; // Paldea
}

/// Etiquetes humanes per al desplegable
const generationLabels = {
  1: 'Gen 1 (Kanto)',
  2: 'Gen 2 (Johto)',
  3: 'Gen 3 (Hoenn)',
  4: 'Gen 4 (Sinnoh)',
  5: 'Gen 5 (Unova)',
  6: 'Gen 6 (Kalos)',
  7: 'Gen 7 (Alola)',
  8: 'Gen 8 (Galar)',
  9: 'Gen 9 (Paldea)',
};

/// Llista de tots els tipus
const List<String> allTypes = [
  'normal','fire','water','electric','grass','ice','fighting','poison',
  'ground','flying','psychic','bug','rock','ghost','dragon',
  'dark','steel','fairy',
];

/// Color opcional per generació (per si vols colorejar)
const generationColors = {
  1: Colors.red,
  2: Colors.green,
  3: Colors.blue,
  4: Colors.orange,
  5: Colors.purple,
  6: Colors.pink,
  7: Colors.brown,
  8: Colors.teal,
  9: Colors.indigo,
};
