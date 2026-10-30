import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';
import 'package:mlc_mobile/features/competences/presentation/competences_providers.dart';
import 'package:mlc_mobile/shared/widgets/competence_card.dart';

class CompetencesListScreen extends ConsumerStatefulWidget {
  const CompetencesListScreen({super.key});

  @override
  ConsumerState<CompetencesListScreen> createState() => _CompetencesListScreenState();
}

class _CompetencesListScreenState extends ConsumerState<CompetencesListScreen> {
  final _recherche = TextEditingController();
  String _filtre = '';

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  /// Compare sans tenir compte des majuscules ni des accents (« electricite » trouve « Électricité »).
  static String _simple(String s) {
    const de = 'àâäáãçéèêëíìîïñóòôöõúùûüýÿœ';
    const vers = 'aaaaaceeeeiiiinooooouuuuyyo';
    final b = StringBuffer();
    for (final c in s.toLowerCase().split('')) {
      final i = de.indexOf(c);
      b.write(i >= 0 ? vers[i] : c);
    }
    return b.toString().trim();
  }

  List<CitoyenCompetence> _filtrer(List<CitoyenCompetence> items) {
    final q = _simple(_filtre);
    if (q.isEmpty) return items;
    return items
        .where((c) => _simple('${c.competenceNom} ${c.secteurNom ?? ''}').contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(competencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes compétences')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/competences/ajouter'),
        icon: const Icon(AppIcons.add),
        label: const Text('Ajouter'),
      ),
      body: AsyncValueView<List<CitoyenCompetence>>(
        value: value,
        onRetry: () => ref.invalidate(competencesProvider),
        isEmpty: (d) => d.isEmpty,
        emptyMessage: 'Vous n\'avez pas encore de compétence.\nAjoutez la première !',
        data: (items) {
          final visibles = _filtrer(items);
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(competencesProvider.future),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: visibles.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    TextField(
                      controller: _recherche,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) => setState(() => _filtre = v),
                      decoration: InputDecoration(
                        labelText: 'Rechercher une compétence',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _filtre.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Effacer la recherche',
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _recherche.clear();
                                  setState(() => _filtre = '');
                                },
                              ),
                      ),
                    ),
                    if (visibles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          'Aucune compétence ne correspond à « ${_filtre.trim()} ».',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ]);
                }
                final c = visibles[i - 1];
                return CompetenceCard(item: c, onTap: () => context.push('/competences/${c.id}'));
              },
            ),
          );
        },
      ),
    );
  }
}
