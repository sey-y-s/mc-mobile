import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/core/utils/validators.dart';
import 'package:mlc_mobile/core/widgets/form_scaffold.dart';
import 'package:mlc_mobile/core/widgets/app_text_field.dart';
import 'package:mlc_mobile/features/auth/domain/auth_repository.dart';
import 'package:mlc_mobile/features/auth/presentation/auth_providers.dart';
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

  @override
  void dispose() {
    for (final c in [_nom, _prenom, _tel, _email, _pwd, _pwd2]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: ajouter un sélecteur Région -> Commune (liste via ApiEndpoints.communes,
    // à fournir par le backend) et passer communeId ici. Obligatoire dès que l'endpoint existe
    // (règle métier : Citoyen 0..* — 1 Commune).
    final ok =
        await ref.read(authControllerProvider.notifier).register(RegisterData(
              nom: _nom.text.trim(),
              prenom: _prenom.text.trim(),
              telephone: _tel.text.replaceAll(RegExp(r'[\s\-.]'), ''),
              email: _email.text.trim().isEmpty ? null : _email.text.trim(),
              password: _pwd.text,
            ));
    // Succès : le routeur redirige vers /home. On ferme l'écran s'il reste dans la pile.
    if (ok && mounted && Navigator.of(context).canPop())
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;
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
      ],
    );
  }
}
