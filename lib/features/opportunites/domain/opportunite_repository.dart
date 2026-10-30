import 'package:mlc_mobile/features/opportunites/domain/opportunite_models.dart';

abstract interface class OpportuniteRepository {
  /// Opportunités visibles ; pour un citoyen : sa commune, puis sa région, puis le reste du Mali.
  Future<List<Opportunite>> list({
    OpportuniteType? type,
    String? categoryId,
    bool presDeChezMoi = false,
    int page = 0,
    int size = 20,
  });
  Future<Opportunite> get(String id);

  /// Candidature du citoyen connecté (une seule par opportunité). Ouverte à tous.
  Future<void> postuler(String id, {String? message});
}
