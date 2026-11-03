import 'package:flutter/material.dart';
import 'package:mlc_mobile/features/portfolio/presentation/portfolio_media_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/media/ouvrir_fichier.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/info_row.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/features/preuves/domain/preuve_models.dart';
import 'package:mlc_mobile/features/preuves/presentation/preuve_providers.dart';

/// Route : /preuves/:id
/// Un document (PDF, Word…) s'ouvre avec l'application de l'appareil ; une image s'affiche directement.

class PreuveDetailScreen extends ConsumerWidget {
  const PreuveDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = this.id;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preuve')),
        body: const ErrorView(error: NotFoundFailure()),
      );
    }
    final value = ref.watch(preuveDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Preuve')),
      body: AsyncValueView<Preuve>(
        value: value,
        onRetry: () => ref.invalidate(preuveDetailProvider(id)),
        data: (p) => _Content(preuve: p),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.preuve});
  final Preuve preuve;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(preuve.type.label, style: text.headlineSmall),
        const SizedBox(height: 16),
        AppCard(
          onTap: () =>
              context.push('/competences/${preuve.citoyenCompetenceId}'),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compétence concernée',
                      style: text.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                    Text(preuve.competenceNom, style: text.titleSmall),
                  ],
                ),
              ),
              const Icon(AppIcons.chevron, color: AppColors.muted),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              InfoRow(label: 'Ajoutée le', value: formatDateFr(preuve.date)),
              InfoRow(
                label: 'Fichier',
                value: preuve.fichierNom ?? 'Non disponible',
              ),
            ],
          ),
        ),
        if (preuve.isImage && preuve.fichierUrl != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            // Fichier privé : chargé avec le jeton de connexion (une NetworkImage échouerait).
            child: PortfolioMediaPreview(
              url: preuve.fichierUrl!,
              height: 220,
              width: double.infinity,
              cacheWidth: 800, // jamais l'image pleine résolution en mémoire
            ),
          ),
        ],
        if (!preuve.isImage && preuve.fichierUrl != null) ...[
          const SizedBox(height: 12),
          _BoutonOuvrir(url: preuve.fichierUrl!, nom: preuve.fichierNom),
        ],
      ],
    );
  }
}

/// Télécharge puis ouvre le document de la preuve.
class _BoutonOuvrir extends ConsumerStatefulWidget {
  const _BoutonOuvrir({required this.url, this.nom});
  final String url;
  final String? nom;

  @override
  ConsumerState<_BoutonOuvrir> createState() => _BoutonOuvrirState();
}

class _BoutonOuvrirState extends ConsumerState<_BoutonOuvrir> {
  bool _enCours = false;

  Future<void> _ouvrir() async {
    setState(() => _enCours = true);
    try {
      await ouvrirFichierProtege(ref, widget.url, nom: widget.nom);
    } catch (e) {
      if (mounted) showError(context, failureMessage(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppButton(
    label: 'Ouvrir le document',
    icon: Icons.open_in_new,
    variant: AppButtonVariant.secondary,
    isLoading: _enCours,
    onPressed: _ouvrir,
  );
}
