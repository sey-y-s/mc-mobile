import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';

class EvaluateurScreen extends ConsumerStatefulWidget {
  const EvaluateurScreen({super.key});
  @override
  ConsumerState<EvaluateurScreen> createState() => _EvaluateurScreenState();
}

class _EvaluateurScreenState extends ConsumerState<EvaluateurScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _centres = [];
  List<Map<String, dynamic>> _demandes = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final centresResponse = await dio.get('/api/v1/evaluateur/mes-centres');
      final demandesResponse = await dio.get('/api/v1/evaluateur/demandes');
      _centres = _maps(centresResponse.data);
      _demandes = _maps(demandesResponse.data);
    } on DioException catch (e) {
      _error = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ?? 'Impossible de charger l’espace évaluateur.')
          : 'Connexion au serveur impossible. Vérifiez votre connexion.';
    } catch (_) { _error = 'Une erreur est survenue lors du chargement.'; }
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _maps(dynamic data) =>
      data is List ? data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : [];

  Future<void> _decide(Map<String, dynamic> item, String status) async {
    final id = item['id']?.toString();
    if (id == null) return;
    final commentaire = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'APPROUVEE' ? 'Valider la compétence' : 'Rejeter la demande'),
        content: TextField(controller: commentaire, maxLines: 3,
          decoration: const InputDecoration(labelText: 'Commentaire (facultatif)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(dioProvider).patch('/api/v1/evaluateur/demandes/$id/decision',
        data: {'statut': status, 'commentaire': commentaire.text.trim()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        status == 'APPROUVEE' ? 'Compétence validée.' : 'Demande rejetée.')));
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ?? 'Décision impossible.'
          : 'Décision impossible. Vérifiez la connexion.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace évaluateur')),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : _error != null ? Center(child: Padding(
          padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 42), const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ])))
        : RefreshIndicator(onRefresh: _load, child: ListView(
          padding: const EdgeInsets.all(16), children: [
            const Text('Mes centres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_centres.isEmpty) const Card(child: Padding(
              padding: EdgeInsets.all(16), child: Text('Aucune désignation active. Demandez à l’administrateur de votre centre de vous désigner comme évaluateur.')))
            else ..._centres.map((c) => Card(child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.verified_user_outlined)),
              title: Text(c['nomCentre']?.toString() ?? 'Centre'),
              subtitle: Text(c['specialite']?.toString().isNotEmpty == true ? 'Spécialité : ${c['specialite']}' : 'Évaluateur désigné'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ))),
            const SizedBox(height: 20),
            Text('Demandes en attente (${_demandes.length})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_demandes.isEmpty) const Card(child: Padding(
              padding: EdgeInsets.all(16), child: Text('Aucune demande de validation pour le moment.')))
            else ..._demandes.map((d) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(padding: const EdgeInsets.all(14), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${d['citoyenPrenom'] ?? ''} ${d['citoyenNom'] ?? 'Citoyen'}'.trim(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Compétence : ${d['competenceNom'] ?? 'Non renseignée'}'),
                  if (d['niveauCompetence'] != null)
                    Text('Niveau déclaré : ${d['niveauCompetence']}'),
                  if (d['centreNom'] != null)
                    Text('Centre : ${d['centreNom']}'),
                  const SizedBox(height: 6),
                  Text('Type : ${d['type']?.toString().replaceAll('_', ' ') ?? 'VALIDATION PRATIQUE'}'),
                  if (d['preuveTitre'] != null) ...[
                    const SizedBox(height: 4),
                    Text('Preuve : ${d['preuveTitre']}'),
                  ],
                  if (d['preuveDescription'] != null && d['preuveDescription'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(d['preuveDescription'].toString()),
                  ],
                  if (d['commentaire']?.toString().isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text('Note : ${d['commentaire']}'),
                  ],
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    FilledButton.icon(onPressed: () => _decide(d, 'APPROUVEE'),
                      icon: const Icon(Icons.check), label: const Text('Valider')),
                    OutlinedButton.icon(onPressed: () => _decide(d, 'REJETEE'),
                      icon: const Icon(Icons.close), label: const Text('Rejeter')),
                  ]),
                ],
              )),
            )),
          ],
        )),
    );
  }
}
