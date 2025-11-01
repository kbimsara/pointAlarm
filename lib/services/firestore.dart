import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference alarms = FirebaseFirestore.instance.collection('alarms');

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
