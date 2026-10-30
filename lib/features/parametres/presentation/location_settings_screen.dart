import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/location/position_ponctuelle.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/choice_sheet_field.dart';
import 'package:mlc_mobile/core/widgets/section_header.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/features/parametres/data/localisation_repository.dart';
import 'package:mlc_mobile/features/parametres/presentation/settings_providers.dart';
import 'package:mlc_mobile/features/parametres/presentation/suggestion_commune_card.dart';
import 'package:mlc_mobile/features/passport/domain/passport_models.dart';
import 'package:mlc_mobile/features/passport/presentation/passport_providers.dart';

/// Route : /parametres/localisation
/// Votre commune de référence : vous la choisissez vous-même, ou vous confirmez une commune
/// détectée ponctuellement par le GPS. Aucune position n'est conservée.
class LocationSettingsScreen extends ConsumerWidget {
  const LocationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(maLocalisationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ma commune')),
      body: AsyncValueView<MaLocalisation>(
        value: value,
        onRetry: () => ref.invalidate(maLocalisationProvider),
        data: (loc) => _Corps(loc: loc),
      ),
    );
  }
}

class _Corps extends ConsumerStatefulWidget {
  const _Corps({required this.loc});
  final MaLocalisation loc;

  @override
  ConsumerState<_Corps> createState() => _CorpsState();
}

class _CorpsState extends ConsumerState<_Corps> {
  bool _busy = false;
  bool _changer = false;
  String? _regionId;
  String? _communeId;
  String? _erreur;
  bool _reglages = false;

  LocalisationRepository get _repo => ref.read(localisationRepositoryProvider);

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _erreur = null;
      _reglages = false;
    });
    try {
      await action();
    } on PositionIndisponible catch (e) {
      _erreur = e.message;
      _reglages = e.ouvrirReglages;
    } catch (e) {
      _erreur = e is AppFailure ? e.message : failureMessage(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enregistrerCommune() => _run(() async {
    await _repo.declarer(_communeId!);
    ref
      ..invalidate(maLocalisationProvider)
      ..invalidate(passportProvider);
    _changer = false;
    if (mounted) showSuccess(context, 'Commune enregistrée');
  });

  Future<void> _consentement(bool v) => _run(() async {
    await _repo.consentement(v);
    ref
      ..invalidate(maLocalisationProvider)
      ..invalidate(passportProvider);
    if (v && mounted) await _verifier();
  });

  Future<void> _verifier() => _run(() async {
    final p = await lirePositionUneFois();
    final d = await _repo.detecter(p.latitude, p.longitude);
    ref
      ..invalidate(maLocalisationProvider)
      ..invalidate(passportProvider);
    if (mounted && d.resultat != ResultatDetection.suggestionCreee) {
      showSuccess(context, d.message);
    }
  });

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          accentColor: loc.communeConnue ? AppColors.green : null,
          child: Row(
            children: [
              Icon(
                loc.communeConnue ? Icons.location_city : Icons.help_outline,
                color: loc.communeConnue ? AppColors.green : AppColors.muted,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre commune de référence',
                      style: text.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                    Text(loc.libelle, style: text.titleMedium),
                    if (loc.source != null)
                      Text(
                        '${loc.source!.label}${loc.confirmeeLe != null ? ' · ${formatDateFr(loc.confirmeeLe!)}' : ''}',
                        style: text.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (loc.suggestion != null) ...[
          const SizedBox(height: 12),
          SuggestionCommuneCard(
            suggestion: loc.suggestion!,
            communeActuelle: loc.communeNom,
          ),
        ],
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _changer
              ? _choixCommune()
              : AppButton(
                  label: loc.communeConnue
                      ? "J'ai déménagé : changer de commune"
                      : 'Choisir ma commune',
                  icon: Icons.edit_location_alt_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: _busy
                      ? null
                      : () => setState(() => _changer = true),
                ),
        ),
        const SizedBox(height: 28),
        const SectionHeader(title: 'Détection de ma commune'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: loc.gpsConsenti,
                onChanged: _busy ? null : _consentement,
                title: const Text('Me proposer ma commune grâce au GPS'),
                subtitle: const Text(
                  "Facultatif. À l'ouverture de l'application, votre position sert une seule fois à trouver votre commune.",
                ),
              ),
              const Divider(height: 20),
              const _Garantie(
                icone: Icons.no_sim_outlined,
                texte: "Votre position n'est jamais enregistrée : ni sur le téléphone, ni sur le serveur.",
              ),
              const _Garantie(
                icone: Icons.verified_user_outlined,
                texte: 'Votre commune ne change jamais sans votre accord.',
              ),
              const _Garantie(
                icone: Icons.travel_explore_outlined,
                texte: 'En voyage ? Refusez la proposition : votre commune reste la même.',
              ),
              if (loc.gpsConsenti) ...[
                const SizedBox(height: 12),
                AppButton(
                  label: 'Vérifier maintenant',
                  icon: Icons.my_location,
                  variant: AppButtonVariant.secondary,
                  isLoading: _busy,
                  onPressed: _verifier,
                ),
              ],
            ],
          ),
        ),
        if (_erreur != null) ...[
          const SizedBox(height: 12),
          Text(_erreur!, style: const TextStyle(color: AppColors.error)),
          if (_reglages)
            TextButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text("Ouvrir les réglages de l'application"),
            ),
        ],
      ],
    );
  }

  Widget _choixCommune() {
    final regions = ref.watch(regionsProvider);
    final communes = _regionId == null
        ? null
        : ref.watch(communesProvider(_regionId!));
    final region = regions.asData?.value
        .where((r) => r.id == _regionId)
        .firstOrNull;
    final commune = communes?.asData?.value
        .where((c) => c.id == _communeId)
        .firstOrNull;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChoiceSheetField<Region>(
            label: 'Région',
            options: regions.asData?.value ?? const [],
            labelOf: (r) => r.nom,
            selected: region,
            enabled: !_busy,
            isLoading: regions.isLoading,
            onChanged: (r) => setState(() {
              _regionId = r.id;
              _communeId = null;
            }),
          ),
          const SizedBox(height: 12),
          ChoiceSheetField<Commune>(
            label: 'Commune',
            placeholder: _regionId == null
                ? "Choisissez d'abord la région"
                : 'Choisir',
            options: communes?.asData?.value ?? const [],
            labelOf: (c) => c.nom,
            selected: commune,
            enabled: !_busy && _regionId != null,
            isLoading: communes?.isLoading ?? false,
            onChanged: (c) => setState(() => _communeId = c.id),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Enregistrer ma commune',
            isLoading: _busy,
            onPressed: _communeId == null ? null : _enregistrerCommune,
          ),
          TextButton(
            onPressed: _busy ? null : () => setState(() => _changer = false),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

class _Garantie extends StatelessWidget {
  const _Garantie({required this.icone, required this.texte});
  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 18, color: AppColors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(texte, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}
