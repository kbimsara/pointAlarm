import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference alarms = FirebaseFirestore.instance.collection('alarms');

  // Add an alarm
  Future<void> addAlarm(String alarmData, bool isActive, String label, String type) {
    return alarms.add({
      "time": alarmData,
      "isActive": isActive,
      "label": label,
      "type": type,
      "createdAt": Timestamp.now(),
    });
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
}
