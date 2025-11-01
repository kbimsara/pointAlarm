import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference alarms = FirebaseFirestore.instance.collection('alarms');

  // Users collection for simple user records
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  // Add an alarm record. Accepts a map so callers can include optional fields
  Future<void> addAlarm(Map<String, dynamic> alarmData) {
    final data = Map<String, dynamic>.from(alarmData);
    data['createdAt'] = Timestamp.now();
    return alarms.add(data);
  }

  // // Update an alarm
  // Future<void> updateAlarm(String id, Map<String, dynamic> alarmData) {
  //   return alarms.collection('alarms').doc(id).update(alarmData);
  // }

  // // Delete an alarm
  // Future<void> deleteAlarm(String id) {
  //   return alarms.collection('alarms').doc(id).delete();
  // }

  // // Get alarms
  // Stream<QuerySnapshot> getAlarms() {
  //   return alarms.collection('alarms').snapshots();
  // }
  
  // Real-time stream of alarms
  Stream<QuerySnapshot> getAlarmsStream() {
    return alarms.orderBy('createdAt', descending: true).snapshots();
  }

  // Stream alarms filtered by user name (expects alarm documents to include a 'user' field)
  Stream<QuerySnapshot> getAlarmsStreamForUser(String userName) {
    return alarms
        .where('user', isEqualTo: userName)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Create a simple user record (id auto-generated). This is optional but useful to track known users.
  Future<DocumentReference> createUser(String name) {
    final data = {'name': name, 'createdAt': Timestamp.now()};
    return users.add(data);
  }

  // One-time query: get alarms for a specific user
  Future<QuerySnapshot> getAlarmsForUserOnce(String userName) {
    // Avoid ordering on the server to prevent requiring a composite index
    // (where + orderBy on different fields can require an index). The caller
    // in the UI only checks for existence or inspects docs; ordering can be
    // done client-side if needed.
    return alarms.where('user', isEqualTo: userName).get();
  }

  // One-time query: get alarms that have no user field (unowned)
  Future<QuerySnapshot> getUnownedAlarmsOnce() {
    return alarms.where('user', isNull: true).get();
  }

  // Assign all currently unowned alarms to a given user using a batch write
  Future<void> assignUnownedAlarmsToUser(String userName) async {
    final qs = await getUnownedAlarmsOnce();
    if (qs.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in qs.docs) {
      batch.update(doc.reference, {'user': userName});
    }
    await batch.commit();
  }

  // Update an existing alarm document
  Future<void> updateAlarm(String id, Map<String, dynamic> alarmData) {
    return alarms.doc(id).update(alarmData);
  }

  // Get a single alarm document by id
  Future<DocumentSnapshot> getAlarmById(String id) {
    return alarms.doc(id).get();
  }

  // Delete an alarm document
  Future<void> deleteAlarm(String id) {
    return alarms.doc(id).delete();
  }
}
