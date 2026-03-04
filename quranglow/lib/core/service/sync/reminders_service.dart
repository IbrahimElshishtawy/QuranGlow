import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quranglow/core/model/reminder/reminder.dart';
import 'package:quranglow/core/utils/logger.dart';

class RemindersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _remindersCol {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(user.uid).collection('reminders');
  }

  Future<void> saveReminder(Reminder reminder) async {
    try {
      await _remindersCol.doc(reminder.id.toString()).set(
        {
          ...reminder.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      L.d('RemindersService', 'Reminder saved to Firestore');
    } catch (e, st) {
      L.e('RemindersService', 'Failed to save reminder', st);
    }
  }

  Future<void> deleteReminder(int id) async {
    try {
      await _remindersCol.doc(id.toString()).delete();
      L.d('RemindersService', 'Reminder deleted from Firestore');
    } catch (e, st) {
      L.e('RemindersService', 'Failed to delete reminder', st);
    }
  }

  Future<List<Reminder>> fetchReminders() async {
    try {
      final snapshot = await _remindersCol.get();
      return snapshot.docs
          .map((doc) => Reminder.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      L.e('RemindersService', 'Failed to fetch reminders', st);
      return [];
    }
  }
}
