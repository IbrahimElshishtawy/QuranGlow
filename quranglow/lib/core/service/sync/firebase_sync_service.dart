import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:quranglow/core/service/sync/firebase_guard.dart';
import 'package:quranglow/core/utils/logger.dart';

class FirebaseSyncService {
  FirebaseFirestore? get _firestore =>
      FirebaseGuard.isReady ? FirebaseFirestore.instance : null;

  FirebaseAuth? get _auth => FirebaseGuard.isReady ? FirebaseAuth.instance : null;

  Future<void> syncTasbih(Map<String, dynamic> data) async {
    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;
    if (user == null || firestore == null) return;
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('azkar')
          .doc('tasbih')
          .set({
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      L.d('FirebaseSyncService', 'Tasbih synced successfully');
    } catch (e, st) {
      L.e('FirebaseSyncService', 'Failed to sync tasbih', st);
    }
  }

  Future<void> syncStats(Map<String, dynamic> stats) async {
    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;
    if (user == null || firestore == null) return;

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('current')
          .set({
            ...stats,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      L.d('FirebaseSyncService', 'Stats synced successfully');
    } catch (e, st) {
      L.e('FirebaseSyncService', 'Failed to sync stats', st);
      if (FirebaseGuard.isReady) {
        FirebaseCrashlytics.instance.recordError(
          e,
          st,
          reason: 'Failed to sync stats to Firestore',
        );
      }
    }
  }

  Future<void> syncBookmarks(List<Map<String, dynamic>> bookmarks) async {
    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;
    if (user == null || firestore == null) return;

    try {
      final batch = firestore.batch();
      final bookmarksCol = firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks');

      for (final bookmark in bookmarks) {
        final docRef = bookmarksCol.doc('${bookmark['surah']}_${bookmark['ayah']}');
        batch.set(docRef, {
          ...bookmark,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      L.d('FirebaseSyncService', 'Bookmarks synced successfully');
    } catch (e, st) {
      L.e('FirebaseSyncService', 'Failed to sync bookmarks', st);
    }
  }

  Future<void> signInAnonymously() async {
    final auth = _auth;
    if (auth == null) return;
    try {
      await auth.signInAnonymously();
      L.d('FirebaseSyncService', 'Signed in anonymously');
    } catch (e, st) {
      L.e('FirebaseSyncService', 'Failed to sign in anonymously', st);
    }
  }
}
