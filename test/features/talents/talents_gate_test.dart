import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/features/mise_en_relation/domain/mise_en_relation_models.dart';
import 'package:mlc_mobile/features/mise_en_relation/domain/mise_en_relation_repository.dart';
import 'package:mlc_mobile/features/mise_en_relation/presentation/mise_en_relation_providers.dart';
import 'package:mlc_mobile/features/mise_en_relation/presentation/relation_detail_screen.dart';
import 'package:mlc_mobile/features/admin/presentation/admin_providers.dart';
import 'package:mlc_mobile/features/passport/domain/profile_completion.dart';
import 'package:mlc_mobile/features/passport/presentation/passport_providers.dart';
import 'package:mlc_mobile/features/talents/presentation/talents_search_screen.dart';

class _Relations implements MiseEnRelationRepository {
  _Relations(this.item);
  final MiseEnRelation item;

  @override
  Future<MiseEnRelation> get(String id) async => item;
  @override
  Future<List<MiseEnRelation>> listReceived({int page = 0, int size = 20}) async => const [];
  @override
  Future<List<MiseEnRelation>> listSent({int page = 0, int size = 20}) async => const [];
  @override
  Future<MiseEnRelation> send(String talentId, {String? message}) => throw UnimplementedError();
  @override
  Future<MiseEnRelation> respond(String id, {required bool accept}) => throw UnimplementedError();
  @override
  Future<MiseEnRelation> cancel(String id) => throw UnimplementedError();
}

void main() {
  testWidgets('un profil incomplet ne peut pas rechercher de talents', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileCompletionProvider.overrideWithValue(
            const AsyncData(
              ProfileCompletion([
                CompletionStep(title: 'Photo', hint: 'Ajoutez une photo de vous', done: false, route: '/passeport/profil'),
              ]),
            ),
          ),
        ],
        child: const MaterialApp(home: TalentsSearchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Compléter mon passeport'), findsOneWidget);
    expect(find.text('Rechercher'), findsNothing);
  });

  MiseEnRelation relation({required String status}) => MiseEnRelation(
        id: 'r-1',
        senderId: 'moi',
        recipientId: 'lui',
        status: RelationStatus.fromApi(status),
        message: 'Bonjour',
        requestedAt: DateTime(2026, 10, 30),
        senderName: 'Moi Même',
        recipientName: 'Aminata Traoré',
        contact: const RelationContact(telephone: '+22370000000'),
      );

  Future<void> ouvrir(WidgetTester tester, MiseEnRelation item) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          miseEnRelationRepositoryProvider.overrideWithValue(_Relations(item)),
          currentUserIdProvider.overrideWith((ref) async => 'moi'),
        ],
        child: const MaterialApp(home: RelationDetailScreen(id: 'r-1')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('celui qui a envoyé la demande ne peut ni l’accepter ni la refuser, il peut l’annuler', (tester) async {
    await ouvrir(tester, relation(status: 'EN_ATTENTE'));

    expect(find.text('Accepter la demande'), findsNothing);
    expect(find.text('Annuler ma demande'), findsOneWidget);
  });

  testWidgets('après acceptation, l’émetteur voit le nom et les coordonnées de l’autre et peut ouvrir son profil', (tester) async {
    await ouvrir(tester, relation(status: 'ACCEPTEE'));

    expect(find.text('Aminata Traoré'), findsOneWidget);
    expect(find.text('+22370000000'), findsOneWidget);
    expect(find.text('Voir son profil'), findsOneWidget);
  });
}
