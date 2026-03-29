import 'package:flutter/material.dart';
import 'package:point_alarm/Components/alarmCard.dart';
import 'package:point_alarm/Pages/setAlarmPage.dart';
import 'package:point_alarm/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_alarm/services/alarm_monitor.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final FirestoreService firestoreService = FirestoreService();
  String? currentUser;
  final TextEditingController _userNameController = TextEditingController();
  final _alarmMonitor = AlarmMonitor();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissions();
      _alarmMonitor.start(user: currentUser);
    });
  }

  Future<void> _requestPermissions() async {
    // Location permission
    await Permission.location.request();
    // Background location (Android 10+)
    if (await Permission.location.isGranted) {
      await Permission.locationAlways.request();
    }
    // Notification permission (Android 13+)
    await Permission.notification.request();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Keep the monitor alive — it uses a Timer that survives pause,
    // but restart if it was previously stopped.
    if (state == AppLifecycleState.resumed) {
      _alarmMonitor.start(user: currentUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1E1E1E),
      appBar: appBar(),
      body: Container(
        margin: const EdgeInsets.only(top: 30),
        child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getAlarmsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
                final allDocs = snapshot.data!.docs;
                final docs = (currentUser != null && currentUser!.isNotEmpty)
                    ? allDocs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final u = (data['user'] ?? '').toString().trim().toLowerCase();
                        final cu = currentUser!.trim().toLowerCase();
                        return u.isNotEmpty && u == cu;
                      }).toList()
                    : allDocs;
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  'No Alarms Set',
                  style: TextStyle(
                    color: Color.fromARGB(255, 184, 181, 181),
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              shrinkWrap: true,
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final nb = data['notifyBeforeKm'];
                final double? notifyBeforeKm =
                    (nb is num)
                        ? nb.toDouble()
                        : (nb != null ? double.tryParse(nb.toString()) : null);
                return AlarmCard(
                  id: doc.id,
                  label: data['label'] ?? '',
                  description: data['type'] ?? data['description'] ?? '',
                  notifyBeforeKm: notifyBeforeKm,
                  isActive: data['isActive'] ?? false,
                  createdBy: data['user'] ?? null,
                  createdAt: data['createdAt'] ?? null,
                );
              },
            );
          },
        ),
      ),
      //floatig action button
      floatingActionButton: FloatingActionButton(
        // onPressed: openBox,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AlarmPage(
                    id: null,
                    label: null,
                    description: null,
                    isActive: null,
                    userName: currentUser,
                  ),
            ),
          );
        },
        backgroundColor: Color(0xff31363F),
        child: Icon(Icons.add),
        foregroundColor: Color(0xff76ABAE),
      ),
    );
  }

  //App bar
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alarmMonitor.stop();
    _userNameController.dispose();
    super.dispose();
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Color(0xff1E1E1E),
      title: Text('Alarm'),
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Stop alarms',
          icon: Icon(Icons.stop_circle_outlined),
          color: Color(0xff76ABAE),
          onPressed: () async {
            await _alarmMonitor.acknowledgeAll();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stopped all alarms')));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(
            child: Text(
              currentUser != null && currentUser!.isNotEmpty
                  ? currentUser!
                  : '',
              style: const TextStyle(color: Color(0xffEEEEEE)),
            ),
          ),
        ),
        IconButton(
          tooltip: 'User',
          icon: Icon(Icons.person),
          color: Color(0xff76ABAE),
          onPressed: () {
            _userNameController.text = currentUser ?? '';
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Color(0xff31363F),
                  title: Text('User', style: TextStyle(color: Colors.white)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _userNameController,
                        style: TextStyle(color: Color(0xffEEEEEE)),
                        decoration: InputDecoration(
                          hintText: 'Enter user name',
                          hintStyle: TextStyle(color: Color(0xffAAAAAA)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff76ABAE)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final name = _userNameController.text.trim();
                              if (name.isEmpty) return;
                              try {
                                await firestoreService.createUser(name);
                                setState(() {
                                  currentUser = name;
                                });
                                _alarmMonitor.updateUser(name);
                                if (!mounted) return;
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Created user: $name'),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                await showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        backgroundColor: Color(0xff31363F),
                                        title: Text(
                                          'Create failed',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: Text(
                                          '$e',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Color(0xff76ABAE),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff76ABAE),
                            ),
                            child: Text(
                              'Create New',
                              style: TextStyle(color: Color(0xff1E1E1E)),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final name = _userNameController.text.trim();
                              if (name.isEmpty) return;
                              try {
                                final qs = await firestoreService
                                    .getAlarmsForUserOnce(name);
                                if (qs.docs.isEmpty) {
                                  // No alarms found for this user — offer to assign unowned alarms
                                  final assign = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          backgroundColor: Color(0xff31363F),
                                          title: Text(
                                            'No alarms found',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          content: Text(
                                            'No alarms are currently associated with "$name".\n\nWould you like to assign existing unowned alarms to this user?',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx,
                                                  ).pop(false),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Color(0xff76ABAE),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx,
                                                  ).pop(true),
                                              child: Text(
                                                'Assign',
                                                style: TextStyle(
                                                  color: Color(0xff76ABAE),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (assign == true) {
                                    // perform assignment of unowned alarms
                                    await firestoreService
                                        .assignUnownedAlarmsToUser(name);
                                    setState(() {
                                      currentUser = name;
                                    });
                                    _alarmMonitor.updateUser(name);
                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Assigned unowned alarms to $name',
                                        ),
                                      ),
                                    );
                                  } else {
                                    // just set the current user (no alarms yet)
                                  setState(() {
                                    currentUser = name;
                                  });
                                  _alarmMonitor.updateUser(name);
                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Loaded user: $name (no alarms)',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  // user has alarms — just load
                                  setState(() {
                                    currentUser = name;
                                  });
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Loaded user: $name'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!mounted) return;
                                await showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        backgroundColor: Color(0xff31363F),
                                        title: Text(
                                          'Load failed',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: Text(
                                          '$e',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Color(0xff76ABAE),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff31363F),
                              side: BorderSide(color: Color(0xff76ABAE)),
                            ),
                            child: Text(
                              'Load',
                              style: TextStyle(color: Color(0xff76ABAE)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
