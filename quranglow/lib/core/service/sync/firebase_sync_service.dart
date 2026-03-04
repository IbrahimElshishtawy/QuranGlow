import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quranglow/core/utils/logger.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> syncTasbih(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('azkar')
          .doc('tasbih')
          .set(
            {
              ...data,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
      L.d('FirebaseSyncService', 'Tasbih synced successfully');
    } catch (e, st) {
      L.e('FirebaseSyncService', 'Failed to sync tasbih', st);
    }
  }

  Future<void> syncStats(Map<String, dynamic> stats) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).collection('stats').doc('current').set(
        {
          ...stats,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      L.d('FirebaseSyncService', 'Stats synced successfully');
    } catch (e, st) {
      L.e('FirebaseSyncService', 'Failed to sync stats', st);
    }
  }

  Future<void> syncBookmarks(List<Map<String, dynamic>> bookmarks) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final batch = _firestore.batch();
      final bookmarksCol = _firestore.collection('users').doc(user.uid).collection('bookmarks');

      // Simple implementation: overwrite all bookmarks
      // In a real app, you might want a more sophisticated merge strategy
      for (var bookmark in bookmarks) {
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
    try {
      await _auth.signInAnonymously();
      L.d('FirebaseSyncService', 'Signed in anonymously');
    } catch (e, st) {
      L.e('FirebaseSyncService', 'Failed to sign in anonymously', st);
    }
  }
}
