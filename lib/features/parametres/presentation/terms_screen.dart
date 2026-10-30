import 'package:flutter/material.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';

/// Route : /conditions (lisible avant l'inscription comme depuis « Plus »).
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _version = 'Version 1.0 · Dernière mise à jour : octobre 2026';

  static const _sections = <(String, String)>[
    (
      '1. Objet du service',
      'MaliCompétences est une plateforme qui permet à chaque citoyen de faire connaître et reconnaître ses '
          'compétences, qu’elles viennent de l’école, de la formation ou du travail sur le terrain. Elle met en '
          'relation les citoyens avec des organisations et des opportunités (emploi, formation, appels à '
          'candidatures). L’utilisation du service est gratuite pour le citoyen.',
    ),
    (
      '2. Votre compte',
      'Vous créez un compte avec votre numéro de téléphone, que vous confirmez grâce à un code reçu par SMS ou '
          'par e-mail. Les informations données à l’inscription (nom, prénom, commune, sexe) doivent être exactes. '
          'Vous êtes responsable de la confidentialité de votre mot de passe : ne le communiquez à personne. '
          'Un compte est personnel et ne peut pas être prêté ou cédé.',
    ),
    (
      '3. Vos compétences et leur validation',
      'Une compétence passe par quatre étapes : déclarée (vous l’annoncez), preuve reçue (vous joignez un '
          'justificatif), en cours d’évaluation, puis validée. Selon la compétence, la validation peut se faire par '
          'l’examen de vos justificatifs par l’équipe de la plateforme, par un test en ligne, par une évaluation '
          'pratique dans un centre agréé, sur votre portfolio ou par un maître artisan référent. Le parcours vous est '
          'proposé par l’application. Une compétence non validée n’est pas rejetée : elle reste visible comme '
          'déclarée.',
    ),
    (
      '4. Justificatifs et documents',
      'Vous ne déposez que des documents authentiques qui vous concernent (diplôme, certificat, attestation, '
          'photos ou vidéos de vos réalisations). Déposer un faux document, ou un document appartenant à une autre '
          'personne, entraîne le rejet de la demande et peut entraîner la suspension du compte. Vos documents ne sont '
          'consultables que par vous et par les personnes chargées de les examiner.',
    ),
    (
      '5. Données personnelles et localisation',
      'Nous collectons uniquement les données utiles au service : identité, coordonnées, commune, compétences, '
          'expériences et résultats de tests. Votre position GPS, si vous l’autorisez, sert une seule fois à proposer '
          'votre commune ; elle n’est jamais enregistrée, ni sur votre téléphone, ni sur nos serveurs, et votre commune '
          'ne change jamais sans votre accord. Les données sont traitées conformément à la législation malienne en '
          'vigueur sur la protection des données personnelles. Vous pouvez à tout moment corriger vos informations '
          'depuis l’application.',
    ),
    (
      '6. Visibilité de votre profil',
      'Les organisations qui recherchent des talents ne voient qu’un profil anonymisé : compétences, niveau, '
          'disponibilité et zone géographique. Vos coordonnées ne leur sont transmises que si vous acceptez une '
          'demande de mise en relation. Vous pouvez refuser une demande sans avoir à vous justifier.',
    ),
    (
      '7. Décisions et contestations',
      'Une décision de validation n’est jamais modifiée en silence. Si vous pensez qu’elle est injuste, vous '
          'pouvez la contester depuis le détail de la validation : elle est alors réexaminée, et si la contestation '
          'est acceptée, une nouvelle décision est enregistrée.',
    ),
    (
      '8. Comportement attendu',
      'Vous vous engagez à utiliser la plateforme de bonne foi, à respecter les autres utilisateurs, les '
          'évaluateurs et les organisations, et à ne pas tenter de perturber le service ou d’accéder aux données '
          'd’autrui.',
    ),
    (
      '9. Suspension et fermeture du compte',
      'L’équipe de la plateforme peut suspendre un compte en cas de fraude, d’usurpation d’identité ou de '
          'non-respect de ces conditions. Vous pouvez demander la fermeture de votre compte à tout moment auprès de '
          'l’équipe MaliCompétences.',
    ),
    (
      '10. Évolution des conditions',
      'Ces conditions peuvent évoluer pour suivre le service ou la réglementation. En cas de changement important, '
          'vous en serez informé dans l’application. Continuer à utiliser le service après cette information '
          'vaut acceptation des nouvelles conditions.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d’utilisation')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(
              'Conditions d’utilisation de MaliCompétences',
              style: text.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _version,
              style: text.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Text(
              'En créant un compte, vous acceptez les règles ci-dessous. Elles sont écrites pour être lues : '
              'prenez le temps de les parcourir.',
              style: text.bodyMedium?.copyWith(
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            for (final (titre, corps) in _sections) ...[
              const SizedBox(height: 20),
              Text(
                titre,
                style: text.titleMedium?.copyWith(color: AppColors.green),
              ),
              const SizedBox(height: 6),
              Text(corps, style: text.bodyMedium?.copyWith(height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}
