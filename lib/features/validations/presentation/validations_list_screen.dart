import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/filter_chips.dart';
import 'package:mlc_mobile/core/widgets/paginated_list_view.dart';
import 'package:mlc_mobile/features/validations/domain/validation_models.dart';
import 'package:mlc_mobile/features/validations/domain/validation_statut.dart';
import 'package:mlc_mobile/features/validations/presentation/validation_labels.dart';
import 'package:mlc_mobile/features/validations/presentation/validation_providers.dart';
import 'package:mlc_mobile/shared/widgets/validation_tile.dart';

/// Route : /validations
class ValidationsListScreen extends ConsumerStatefulWidget {
  const ValidationsListScreen({super.key});

  @override
  ConsumerState<ValidationsListScreen> createState() => _ValidationsListScreenState();
}

class _ValidationsListScreenState extends ConsumerState<ValidationsListScreen> {
  ValidationStatut? _statut;

  @override
  Widget build(BuildContext context) {
    final revision = ref.watch(validationsRevisionProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes validations'),
        actions: [
          IconButton(tooltip: 'Historique', icon: const Icon(AppIcons.history), onPressed: () => context.push('/validations/historique')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/validations/demander'),
        icon: const Icon(AppIcons.add),
        label: const Text('Demander'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: FilterChips<ValidationStatut>(
            options: ValidationStatut.values,
            labelOf: (s) => s.label,
            selected: _statut,
            onChanged: (v) => setState(() => _statut = v),
          ),
        ),
        Expanded(
          child: PaginatedListView<Validation>(
            key: ValueKey('$revision-${_statut?.apiCode}'), // filtre ou demande : la liste se recharge
            emptyMessage: _statut == null
                ? "Aucune validation pour l'instant.\nAjoutez une preuve, puis demandez une validation."
                : 'Aucune validation « ${_statut!.label.toLowerCase()} ».',
            fetchPage: (page, size) => ref.read(validationRepositoryProvider).listMine(statut: _statut, page: page, size: size),
            itemBuilder: (_, v) => ValidationTile(
              competenceNom: v.competenceNom,
              typeLabel: v.type.label,
              statut: v.statut,
              dateLabel: validationDateLabel(v),
              validateurLabel: v.validateurLabel,
              onTap: () => context.push('/validations/${v.id}'),
            ),
          ),
        ),
      ]),
    );
  }
}