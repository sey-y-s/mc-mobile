import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';
import 'package:mlc_mobile/features/competences/presentation/competences_providers.dart';
import 'package:mlc_mobile/features/experiences/presentation/experience_providers.dart';
import 'package:mlc_mobile/features/passport/data/api_cv_repository.dart';
import 'package:mlc_mobile/features/preuves/presentation/preuve_providers.dart';

class CvScreen extends ConsumerStatefulWidget {
  const CvScreen({super.key});

  @override
  ConsumerState<CvScreen> createState() => _CvScreenState();
}

class _CvScreenState extends ConsumerState<CvScreen> {
  bool _isDownloading = false;

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    try {
      if (AppConfig.useMocks) {
        throw const FeatureUnavailableFailure(
          'Connectez-vous au backend pour générer votre CV.',
        );
      }
      final bytes = await ref.read(cvRepositoryProvider).download();
      final path = await FilePicker.saveFile(
        dialogTitle: 'Enregistrer mon CV',
        fileName: 'mon-cv.pdf',
        bytes: bytes,
      );
      if (path != null && mounted) {
        showSuccess(context, 'Votre CV a été téléchargé.');
      }
    } catch (error) {
      if (mounted) showError(context, failureMessage(error));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Le serveur applique la même règle : un CV s'appuie sur du vérifié.
    final competences = ref.watch(competencesProvider).value;
    final experiences = ref.watch(recentExperiencesProvider).value;
    final preuves = ref.watch(recentPreuvesProvider).value;
    final valide = competences?.any((c) => c.etat == EtatCompetence.validee) ?? false;
    final contexte = (experiences?.isNotEmpty ?? false) || (preuves?.isNotEmpty ?? false);
    final pret = valide && contexte;
    return Scaffold(
      appBar: AppBar(title: const Text('Mon CV')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Icon(
            Icons.description_outlined,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Un CV à jour, prêt à partager',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Votre CV est généré à partir des informations de votre passeport : '
            'photo de profil, coordonnées, compétences validées, expériences '
            'et résultats de tests numériques.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _Conditions(valide: valide, contexte: contexte),
          const SizedBox(height: 16),
          AppButton(
            label: 'Générer et télécharger le CV',
            icon: Icons.download_outlined,
            isLoading: _isDownloading,
            onPressed: pret ? _download : null,
          ),
          const SizedBox(height: 12),
          Text(
            'Le fichier sera enregistré au format PDF sur votre appareil.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Les deux conditions pour obtenir un CV, avec leur état.
class _Conditions extends StatelessWidget {
  const _Conditions({required this.valide, required this.contexte});
  final bool valide;
  final bool contexte;

  @override
  Widget build(BuildContext context) {
    Widget ligne(bool ok, String texte) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20, color: ok ? AppColors.green : AppColors.muted),
            const SizedBox(width: 10),
            Expanded(child: Text(texte)),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Pour générer votre CV', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      ligne(valide, 'Au moins une compétence validée'),
      ligne(contexte, 'Au moins une expérience ou une preuve ajoutée'),
    ]);
  }
}
