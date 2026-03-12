import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:quranglow/core/model/reminder/reminder.dart';
import 'package:quranglow/core/service/sync/firebase_guard.dart';
import 'package:quranglow/core/utils/logger.dart';

class RemindersService {
  FirebaseFirestore? get _firestore =>
      FirebaseGuard.isReady ? FirebaseFirestore.instance : null;

  FirebaseAuth? get _auth => FirebaseGuard.isReady ? FirebaseAuth.instance : null;

  CollectionReference<Map<String, dynamic>>? get _remindersCol {
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user == null || firestore == null) return null;
    return firestore.collection('users').doc(user.uid).collection('reminders');
  }

  Future<void> saveReminder(Reminder reminder) async {
    final col = _remindersCol;
    if (col == null) return;
    try {
      await col.doc(reminder.id.toString()).set({
        ...reminder.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      L.d('RemindersService', 'Reminder saved to Firestore');
    } catch (e, st) {
      L.e('RemindersService', 'Failed to save reminder', st);
      if (FirebaseGuard.isReady) {
        FirebaseCrashlytics.instance.recordError(
          e,
          st,
          reason: 'Failed to save reminder to Firestore',
        );
      }
    }
  }

  Future<void> deleteReminder(int id) async {
    final col = _remindersCol;
    if (col == null) return;
    try {
      await col.doc(id.toString()).delete();
      L.d('RemindersService', 'Reminder deleted from Firestore');
    } catch (e, st) {
      L.e('RemindersService', 'Failed to delete reminder', st);
    }
  }

  Future<List<Reminder>> fetchReminders() async {
    final col = _remindersCol;
    if (col == null) return [];
    try {
      final snapshot = await col.get();
      return snapshot.docs
          .map((doc) => Reminder.fromMap(doc.data()))
          .toList();
    } catch (e, st) {
      L.e('RemindersService', 'Failed to fetch reminders', st);
      return [];
    }
  }
}
