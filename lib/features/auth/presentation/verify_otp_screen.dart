import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/router/routes.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/utils/validators.dart';
import 'package:mlc_mobile/core/widgets/app_text_field.dart';
import 'package:mlc_mobile/core/widgets/form_scaffold.dart';
import 'package:mlc_mobile/features/auth/domain/auth_repository.dart';
import 'package:mlc_mobile/features/auth/presentation/auth_providers.dart';

/// Route : /verify. Le compte reste bloqué tant qu'un des contacts (téléphone ou e-mail) n'est pas
/// vérifié par le code à 6 chiffres. Le bon code ouvre la session ; le routeur ouvre l'accueil.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});
  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  static const _delaiRenvoi = 60;

  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  CanalVerification? _canal;
  int _attente = 0;
  Timer? _minuteur;
  String? _info;
  String? _erreurRenvoi;
  bool _renvoiEnCours = false;

  @override
  void initState() {
    super.initState();
    final ctx = ref.read(verificationProvider);
    if (ctx == null) return;
    _canal = ctx.canaux.first;
    if (ctx.codeDejaEnvoye) {
      _demarrerAttente();
    } else {
      // Arrivée depuis la connexion : les codes précédents ont pu expirer, on en demande un nouveau.
      WidgetsBinding.instance.addPostFrameCallback((_) => _renvoyer(silencieux: true));
    }
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _demarrerAttente() {
    _minuteur?.cancel();
    setState(() => _attente = _delaiRenvoi);
    _minuteur = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _attente = _attente > 0 ? _attente - 1 : 0);
      if (_attente == 0) t.cancel();
    });
  }

  Future<void> _renvoyer({bool silencieux = false}) async {
    final ctx = ref.read(verificationProvider);
    final canal = _canal;
    if (ctx == null || canal == null || _attente > 0 || _renvoiEnCours) return;
    setState(() {
      _renvoiEnCours = true;
      _erreurRenvoi = null;
      _info = null;
    });
    try {
      await ref.read(authRepositoryProvider).resendOtp(identifiant: ctx.identifiant, canal: canal);
      if (!mounted) return;
      setState(() => _info = silencieux ? null : 'Un nouveau code vient d’être envoyé.');
      _demarrerAttente();
    } on AppFailure catch (e) {
      if (!mounted) return;
      // Depuis la connexion, l'envoi automatique reste discret ; sur demande de l'utilisateur, l'erreur s'affiche.
      if (!silencieux) setState(() => _erreurRenvoi = e.message);
    } finally {
      if (mounted) setState(() => _renvoiEnCours = false);
    }
  }

  Future<void> _valider() async {
    final ctx = ref.read(verificationProvider);
    final canal = _canal;
    if (ctx == null || canal == null || !_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).verifyOtp(
          identifiant: ctx.identifiant,
          canal: canal,
          code: _code.text.trim(),
        );
    if (ok && mounted) showSuccess(context, 'Compte vérifié. Bienvenue !');
    // Succès : la session est ouverte, le routeur redirige vers l'accueil.
  }

  @override
  Widget build(BuildContext context) {
    final ctx = ref.watch(verificationProvider);
    if (ctx == null || _canal == null) {
      // Pas d'inscription ni de connexion en cours (lien direct, application relancée).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;
    final canal = _canal!;
    final text = Theme.of(context).textTheme;
    return FormScaffold(
      title: 'Vérifier mon compte',
      formKey: _formKey,
      submitLabel: 'Valider',
      onSubmit: _valider,
      isLoading: busy,
      error: auth.hasError ? auth.error : null,
      children: [
        Text(
          canal == CanalVerification.email
              ? 'Un code à 6 chiffres a été envoyé à votre adresse e-mail. Saisissez-le pour ouvrir votre compte.'
              : 'Un code à 6 chiffres a été envoyé à votre numéro de téléphone. Saisissez-le pour ouvrir votre compte.',
          style: text.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        if (ctx.canaux.length > 1) ...[
          SegmentedButton<CanalVerification>(
            segments: [
              for (final c in ctx.canaux) ButtonSegment(value: c, label: Text(c.libelle)),
            ],
            selected: {canal},
            onSelectionChanged: busy
                ? null
                : (s) => setState(() {
                      _canal = s.first;
                      _code.clear();
                      _info = null;
                      _erreurRenvoi = null;
                    }),
          ),
          Text(
            'Un seul des deux contacts suffit pour ouvrir votre compte.',
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
        AppTextField(
          label: 'Code reçu',
          controller: _code,
          enabled: !busy,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (v) {
            final r = Validators.resetCode(v);
            if (r != null) return r;
            return v!.trim().length == 6 ? null : 'Le code contient 6 chiffres';
          },
          onSubmitted: (_) => _valider(),
        ),
        if (_info != null) Text(_info!, style: text.bodySmall?.copyWith(color: AppColors.green)),
        if (_erreurRenvoi != null)
          Text(_erreurRenvoi!, style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
        TextButton(
          onPressed: (busy || _attente > 0 || _renvoiEnCours) ? null : _renvoyer,
          child: Text(_attente > 0 ? 'Renvoyer le code dans $_attente s' : 'Renvoyer le code'),
        ),
        TextButton(
          onPressed: busy ? null : () => context.go(AppRoutes.login),
          child: const Text('Retour à la connexion'),
        ),
      ],
    );
  }
}
