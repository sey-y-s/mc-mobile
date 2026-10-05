import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Champs : titre (obligatoire), description, dateRealisation, lienUrl (http/https valide).
//   Médias : un FilePickerField par média (allowed: {image, video, document}, déjà codé : compression des images, limites de taille,
//   aperçu, progression). Envoi via PortfolioRepository.addMedia(id, media, onProgress:) -> uploadMultipart().
//   Mock : MockPortfolioRepository utilise simulateUpload() (core/network/upload.dart) pour simuler l'envoi.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : FormScaffold, AppTextField.
// Route : /portfolio/nouvelle  |  Écran : Nouvelle réalisation
class PortfolioFormScreen extends StatelessWidget {
  const PortfolioFormScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Nouvelle réalisation");
}
