import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';

class CentreAdminEvaluateursScreen extends ConsumerStatefulWidget {
  const CentreAdminEvaluateursScreen({super.key});

  @override
  ConsumerState<CentreAdminEvaluateursScreen> createState() => _CentreAdminEvaluateursScreenState();
}

class _CentreAdminEvaluateursScreenState extends ConsumerState<CentreAdminEvaluateursScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Map<String, dynamic>? _centre;
  List<Map<String, dynamic>> _citoyens = [];
  List<Map<String, dynamic>> _evaluateurs = [];
  String? _citoyenId;
  final _specialite = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _specialite.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _maps(dynamic data) => data is List
      ? data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : [];

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final centreResponse = await dio.get('/api/v1/centre-admin/mon-centre');
      final citoyensResponse = await dio.get('/api/v1/centre-admin/citoyens');
      final evaluateursResponse = await dio.get('/api/v1/centre-admin/evaluateurs');
      _centre = Map<String, dynamic>.from(centreResponse.data as Map);
      _citoyens = _maps(citoyensResponse.data);
      _evaluateurs = _maps(evaluateursResponse.data);
      final already = _evaluateurs.map((e) => e['citoyenId']?.toString()).toSet();
      final available = _citoyens.where((c) => !already.contains(c['id']?.toString())).toList();
      if (_citoyenId != null && !available.any((c) => c['id']?.toString() == _citoyenId)) {
        _citoyenId = null;
      }
    } on DioException catch (e) {
      _error = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ?? 'Chargement impossible.')
          : 'Connexion au serveur impossible.';
    } catch (_) {
      _error = 'Une erreur est survenue pendant le chargement du centre.';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _designer() async {
    if (_citoyenId == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(dioProvider).post('/api/v1/centre-admin/evaluateurs', data: {
        'citoyenId': _citoyenId,
        'specialite': _specialite.text.trim().isEmpty ? null : _specialite.text.trim(),
      });
      if (!mounted) return;
      _specialite.clear();
      setState(() => _citoyenId = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Évaluateur désigné. Son rôle Citoyen est conservé.')));
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map ? e.response?.data['message']?.toString() : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Désignation impossible.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _setActive(Map<String, dynamic> evaluator, bool active) async {
    final id = evaluator['citoyenId']?.toString();
    if (id == null) return;
    try {
      await ref.read(dioProvider).patch('/api/v1/centre-admin/evaluateurs/$id/activation', data: {'actif': active});
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map ? e.response?.data['message']?.toString() : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Modification impossible.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des évaluateurs')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Réessayer')),
                ])))
              : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
                  Card(child: ListTile(leading: const Icon(Icons.school_outlined), title: Text(_centre?['nom']?.toString() ?? 'Mon centre'), subtitle: const Text('Désignez et gérez les évaluateurs agréés de votre centre.'))),
                  const SizedBox(height: 16),
                  Text('Désigner un citoyen', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (_citoyens.where((c) => !_evaluateurs.any((e) => e['citoyenId']?.toString() == c['id']?.toString())).isEmpty)
                    const Text('Aucun autre citoyen disponible pour une nouvelle désignation.')
                  else ...[
                    DropdownButtonFormField<String>(
                      initialValue: _citoyenId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Citoyen à désigner'),
                      items: _citoyens.where((c) => !_evaluateurs.any((e) => e['citoyenId']?.toString() == c['id']?.toString())).map((c) => DropdownMenuItem<String>(
                        value: c['id']?.toString(), child: Text('${c['prenom'] ?? ''} ${c['nom'] ?? ''}'.trim(), overflow: TextOverflow.ellipsis),
                      )).where((item) => item.value != null).toList(),
                      onChanged: _saving ? null : (value) => setState(() => _citoyenId = value),
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: _specialite, decoration: const InputDecoration(labelText: 'Spécialité (ex. mécanique, électricité)', border: OutlineInputBorder()), maxLength: 200),
                    const SizedBox(height: 8),
                    FilledButton.icon(onPressed: _saving || _citoyenId == null ? null : _designer,
                      icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.person_add_alt_1),
                      label: const Text('Désigner comme évaluateur')),
                  ],
                  const SizedBox(height: 24),
                  Text('Évaluateurs du centre (${_evaluateurs.length})', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (_evaluateurs.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Aucun évaluateur n’a encore été désigné.'))),
                  ..._evaluateurs.map((e) => Card(child: SwitchListTile(
                    value: e['actif'] == true,
                    onChanged: (value) => _setActive(e, value),
                    secondary: const Icon(Icons.verified_user_outlined),
                    title: Text('${e['prenomCitoyen'] ?? ''} ${e['nomCitoyen'] ?? ''}'.trim()),
                    subtitle: Text('${e['specialite']?.toString().trim().isNotEmpty == true ? e['specialite'] : 'Spécialité non précisée'} · ${e['actif'] == true ? 'Agrément actif' : 'Agrément suspendu'}'),
                  ))),
                ])),
    );
  }
}
