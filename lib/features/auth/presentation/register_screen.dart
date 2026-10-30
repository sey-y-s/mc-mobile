import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mlc_mobile/app/router/routes.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/location/position_ponctuelle.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/validators.dart';
import 'package:mlc_mobile/core/widgets/choice_sheet_field.dart';
import 'package:mlc_mobile/core/widgets/form_scaffold.dart';
import 'package:mlc_mobile/core/widgets/app_text_field.dart';
import 'package:mlc_mobile/features/auth/domain/auth_repository.dart';
import 'package:mlc_mobile/features/auth/presentation/auth_providers.dart';
import 'package:mlc_mobile/features/passport/domain/passport_models.dart';
import 'package:mlc_mobile/features/passport/presentation/passport_providers.dart';
import 'package:mlc_mobile/l10n/strings.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _tel = TextEditingController();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  String? _regionId;
  String? _communeId;
  Sexe? _sexe;
  bool _conditions = false;
  bool _conditionsErreur = false;
  bool _territoireErreur = false;
  bool _sexeErreur = false;

  // Détection de la position : proposée une fois à l'ouverture, jamais imposée.
  _Detection _detection = _Detection.enAttente;
  String? _detectionMessage;
  Commune? _detectee;
  bool _reglagesProposes = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _proposerDetection());
  }

  @override
  void dispose() {
    for (final c in [_nom, _prenom, _tel, _email, _pwd, _pwd2]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Explique à quoi sert la position AVANT que le système ne demande la permission.
  Future<void> _proposerDetection() async {
    if (!mounted) return;
    final accepte = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.place_outlined, size: 32),
        title: const Text('Trouver votre commune ?'),
        content: const Text(
            'MaliCompétences peut utiliser votre position, une seule fois, pour remplir '
            'votre région et votre commune à votre place. Votre position n’est pas conservée.\n\n'
            'Vous pourrez corriger le résultat, ou tout saisir vous-même.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Je saisis moi-même')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Utiliser ma position')),
        ],
      ),
    );
    if (!mounted) return;
    if (accepte == true) {
      await _detecter();
    } else {
      setState(() => _detection = _Detection.manuelle);
    }
  }

  Future<void> _detecter() async {
    setState(() {
      _detection = _Detection.enCours;
      _detectionMessage = null;
    });
    try {
      final pos = await lirePositionUneFois();
      final commune = await ref
          .read(passportRepositoryProvider)
          .detecterCommune(pos.latitude, pos.longitude);
      if (!mounted) return;
      if (commune == null) {
        setState(() {
          _detection = _Detection.manuelle;
          _detectionMessage =
              'Nous n’avons pas reconnu votre commune. Choisissez-la dans la liste.';
        });
        return;
      }
      setState(() {
        _regionId = commune.regionId;
        _communeId = commune.id;
        _territoireErreur = false;
        _detection = _Detection.trouvee;
        _detectee = commune;
        _detectionMessage = '${commune.nom}, ${commune.regionNom}';
      });
    } on PositionIndisponible catch (e) {
      if (!mounted) return;
      setState(() {
        _detection = _Detection.manuelle;
        _detectionMessage = '${e.message} Choisissez votre commune dans la liste.';
        _reglagesProposes = e.ouvrirReglages;
      });
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _detection = _Detection.manuelle;
        _detectionMessage =
            '${failureMessage(e)} Choisissez votre commune dans la liste.';
      });
    }
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    setState(() {
      _conditionsErreur = !_conditions;
      _territoireErreur = _communeId == null;
      _sexeErreur = _sexe == null;
    });
    if (!formOk || !_conditions || _communeId == null || _sexe == null) return;
    final ok =
        await ref.read(authControllerProvider.notifier).register(RegisterData(
              nom: _nom.text.trim(),
              prenom: _prenom.text.trim(),
              telephone: _tel.text.replaceAll(RegExp(r'[\s\-.]'), ''),
              email: _email.text.trim().isEmpty ? null : _email.text.trim(),
              password: _pwd.text,
              communeId: _communeId,
              sexe: _sexe!.apiCode,
              conditionsAcceptees: _conditions,
            ));
    // Compte créé mais bloqué : la session s'ouvre à la saisie du code reçu.
    if (ok && mounted) context.go(AppRoutes.verify);
  }

  /// Tant que la liste des communes de la région n'est pas chargée, la commune détectée reste affichée.
  Commune? _communeDetectee() =>
      _detectee != null && _detectee!.id == _communeId ? _detectee : null;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;
    final regions = ref.watch(regionsProvider);
    final communes =
        _regionId == null ? null : ref.watch(communesProvider(_regionId!));
    final region =
        regions.asData?.value.where((r) => r.id == _regionId).firstOrNull;
    final commune =
        communes?.asData?.value.where((c) => c.id == _communeId).firstOrNull;
    return FormScaffold(
      title: S.register,
      formKey: _formKey,
      submitLabel: S.register,
      onSubmit: _submit,
      isLoading: busy,
      error: auth.hasError ? auth.error : null,
      children: [
        AppTextField(
            label: 'Nom',
            controller: _nom,
            enabled: !busy,
            textInputAction: TextInputAction.next,
            validator: (v) => Validators.required(v, field: 'Le nom')),
        AppTextField(
            label: 'Prénom',
            controller: _prenom,
            enabled: !busy,
            textInputAction: TextInputAction.next,
            validator: (v) => Validators.required(v, field: 'Le prénom')),
        AppTextField(
            label: 'Téléphone',
            controller: _tel,
            enabled: !busy,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: Validators.phone),
        AppTextField(
            label: 'Email (facultatif)',
            controller: _email,
            enabled: !busy,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.emailOptional),
        _BandeauPosition(
          etat: _detection,
          message: _detectionMessage,
          onReessayer: _detection == _Detection.manuelle ? _detecter : null,
          onReglages: _reglagesProposes ? Geolocator.openAppSettings : null,
        ),
        ChoiceSheetField<Region>(
          label: 'Région',
          options: regions.asData?.value ?? const [],
          labelOf: (r) => r.nom,
          selected: region,
          enabled: !busy && _detection != _Detection.enCours,
          isLoading: regions.isLoading,
          errorText: regions.hasError
              ? failureMessage(regions.error!)
              : (_territoireErreur && _regionId == null
                  ? 'Choisissez votre région.'
                  : null),
          onChanged: (r) => setState(() {
            _regionId = r.id;
            _communeId = null;
          }),
        ),
        ChoiceSheetField<Commune>(
          label: 'Commune',
          placeholder:
              _regionId == null ? "Choisissez d'abord une région" : 'Choisir',
          enabled: !busy && _regionId != null && _detection != _Detection.enCours,
          options: communes?.asData?.value ?? const [],
          labelOf: (c) => c.nom,
          selected: commune ?? _communeDetectee(),
          isLoading: communes?.isLoading ?? false,
          errorText: communes != null && communes.hasError
              ? failureMessage(communes.error!)
              : (_territoireErreur && _regionId != null && _communeId == null
                  ? 'Choisissez votre commune.'
                  : null),
          onChanged: (c) => setState(() {
            _communeId = c.id;
            _territoireErreur = false;
          }),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sexe',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final s in Sexe.values)
              ChoiceChip(
                label: Text(s.label),
                selected: _sexe == s,
                showCheckmark: false,
                onSelected: busy
                    ? null
                    : (_) => setState(() {
                          _sexe = s;
                          _sexeErreur = false;
                        }),
              ),
          ]),
          if (_sexeErreur)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Indiquez votre sexe.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
        ]),
        AppTextField(
            label: 'Mot de passe',
            controller: _pwd,
            obscure: true,
            enabled: !busy,
            textInputAction: TextInputAction.next,
            validator: Validators.password),
        AppTextField(
            label: 'Confirmer le mot de passe',
            controller: _pwd2,
            obscure: true,
            enabled: !busy,
            textInputAction: TextInputAction.done,
            validator: (v) => Validators.confirmPassword(v, _pwd.text)),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _conditions,
          onChanged: busy ? null : (v) => setState(() {
                _conditions = v ?? false;
                if (_conditions) _conditionsErreur = false;
              }),
          title: const Text('J’accepte les conditions d’utilisation de MaliCompétences'),
          subtitle: Text(
            _conditionsErreur
                ? 'Cochez cette case pour créer votre compte.'
                : 'Vos données servent à faire connaître vos compétences ; vous gardez la main sur votre profil.',
            style: TextStyle(color: _conditionsErreur ? Theme.of(context).colorScheme.error : null),
          ),
        ),
      ],
    );
  }
}

enum _Detection { enAttente, enCours, trouvee, manuelle }

/// Résume l'état de la détection : en cours, trouvée (modifiable) ou saisie manuelle (avec « Réessayer »).
class _BandeauPosition extends StatelessWidget {
  const _BandeauPosition({
    required this.etat,
    required this.message,
    this.onReessayer,
    this.onReglages,
  });
  final _Detection etat;
  final String? message;
  final VoidCallback? onReessayer;
  final VoidCallback? onReglages;

  @override
  Widget build(BuildContext context) {
    switch (etat) {
      case _Detection.enAttente:
        return const SizedBox.shrink();
      case _Detection.enCours:
        return const Row(children: [
          SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Expanded(child: Text('Recherche de votre commune…')),
        ]);
      case _Detection.trouvee:
        return Row(children: [
          const Icon(Icons.check_circle_outline, color: AppColors.green),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Commune détectée : $message. Vous pouvez la modifier.')),
        ]);
      case _Detection.manuelle:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(message ?? 'Choisissez votre région et votre commune.'),
          Wrap(children: [
            if (onReessayer != null)
              TextButton(
                  onPressed: onReessayer,
                  child: const Text('Utiliser ma position')),
            if (onReglages != null)
              TextButton(
                  onPressed: onReglages,
                  child: const Text('Ouvrir les réglages')),
          ]),
        ]);
    }
  }
}
