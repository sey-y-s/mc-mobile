import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/features/passport/presentation/passport_providers.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/location/position_ponctuelle.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/features/admin/presentation/admin_providers.dart';
import 'package:mlc_mobile/features/parametres/data/localisation_repository.dart';
import 'package:mlc_mobile/features/parametres/presentation/settings_providers.dart';

/// « Vous semblez être à X. En faire votre commune ? » — le citoyen confirme ou garde sa commune.
class SuggestionCommuneCard extends ConsumerStatefulWidget {
  const SuggestionCommuneCard({super.key, required this.suggestion, this.communeActuelle});
  final SuggestionCommune suggestion;
  final String? communeActuelle;

  @override
  ConsumerState<SuggestionCommuneCard> createState() => _SuggestionCommuneCardState();
}

class _SuggestionCommuneCardState extends ConsumerState<SuggestionCommuneCard> {
  bool _busy = false;

  Future<void> _repondre(bool accepter) async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(localisationRepositoryProvider);
      accepter ? await repo.accepter(widget.suggestion.id) : await repo.refuser(widget.suggestion.id);
      ref..invalidate(maLocalisationProvider)..invalidate(passportProvider);
      if (mounted) {
        showSuccess(context, accepter ? 'Votre commune est mise à jour.' : 'Vous gardez votre commune.');
      }
    } catch (e) {
      if (mounted) showError(context, failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final actuelle = widget.communeActuelle;
    return AppCard(
      accentColor: AppColors.green,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.place_outlined, color: AppColors.green),
          const SizedBox(width: 8),
          Expanded(child: Text('Avez-vous déménagé ?', style: text.titleSmall)),
        ]),
        const SizedBox(height: 6),
        Text(
                    'Vous semblez être en région ${widget.suggestion.regionNom ?? widget.suggestion.libelle}.'
          '${actuelle != null ? ' Votre commune actuelle est $actuelle.' : ''}',
          style: text.bodyMedium,
        ),
        const SizedBox(height: 12),
                AppButton(
          label: 'Choisir ma nouvelle commune',
          isLoading: _busy,
          onPressed: _busy ? null : () => context.push('/parametres/localisation'),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: actuelle != null ? 'Non, je garde $actuelle' : 'Non, pas maintenant',
          variant: AppButtonVariant.secondary,
          onPressed: _busy ? null : () => _repondre(false),
        ),
      ]),
    );
  }
}

/// Une seule détection par ouverture de l'application, et seulement avec le consentement du citoyen.
final detectionFaiteProvider = StateProvider<bool>((ref) => false);

/// Bandeau d'accueil : lance la détection ponctuelle (si autorisée) puis affiche la proposition éventuelle.
class SuggestionCommuneBandeau extends ConsumerStatefulWidget {
  const SuggestionCommuneBandeau({super.key});

  @override
  ConsumerState<SuggestionCommuneBandeau> createState() => _SuggestionCommuneBandeauState();
}

class _SuggestionCommuneBandeauState extends ConsumerState<SuggestionCommuneBandeau> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _detecterUneFois());
  }

  Future<void> _detecterUneFois() async {
    if (!mounted || ref.read(detectionFaiteProvider)) return;
    ref.read(detectionFaiteProvider.notifier).state = true;
    try {
      if (await ref.read(currentRoleProvider.future) != 'CITOYEN') return;
      final loc = await ref.read(maLocalisationProvider.future);
      if (!loc.gpsConsenti || loc.suggestion != null) return;
      // Pas de demande de permission ici : l'application ne dérange pas à l'ouverture.
      final p = await lirePositionUneFois(demanderPermission: false);
      final d = await ref.read(localisationRepositoryProvider).detecter(p.latitude, p.longitude);
      if (d.resultat == ResultatDetection.suggestionCreee) ref..invalidate(maLocalisationProvider)..invalidate(passportProvider);
    } catch (_) {
      // GPS indisponible ou refusé : l'application fonctionne normalement, sans détection.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(currentRoleProvider).value != 'CITOYEN') return const SizedBox.shrink();
    final loc = ref.watch(maLocalisationProvider).asData?.value;
    final s = loc?.suggestion;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: s == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(s.id),
              padding: const EdgeInsets.only(bottom: 16),
              child: SuggestionCommuneCard(suggestion: s, communeActuelle: loc?.communeNom),
            ),
    );
  }
}
