import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'db.dart';

class StudentView extends StatefulWidget {
  QueryDocumentSnapshot student, teacher;
  StudentView(this.student, this.teacher);
  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  QueryDocumentSnapshot? activeSession, attendedSession;
  Duration duration = Duration();
  Future<void> toggleAttendance(String serielNumber) async {
    if (attendedSession != null) {
      await attendedSession!.reference.delete();
    } else if (activeSession != null) {
      await widget.student.reference.collection('atd').add({
        'sn': serielNumber,
        'sessionid': activeSession!.id,
        'time': Timestamp.now()
      });
    }
  }

  Future<void> nfcFound(NfcTag tag) async {
    String? serielNumber = tag.data["mifareultralight"]['identifier']
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
    final validTags = await widget.teacher.reference.collection('tags').get();
    if (validTags.docs.any((doc) => doc.get('sn') == serielNumber)) {
      await toggleAttendance(serielNumber ?? '');
    }
  }

  @override
  void initState() {
    super.initState();
    // if (NfcManager.instance.isAvailable()){
    NfcManager.instance.startSession(onDiscovered: (tag) async {
      await nfcFound(tag);
    });

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream: widget.student.reference.collection('atd').snapshots(),
              builder: (context, atdSnapshot) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Total Attendance: ${(atdSnapshot.data?.size ?? 0)}',
                        style: TextStyle(fontSize: 30),
                      ),
                      StreamBuilder(
                          stream: DB().getActiveSession(widget.teacher),
                          builder: (context, activeSessionData) {
                            String? sessionStatus = attendedSession != null
                                ? 'Attendance marked'
                                : ''; /*activeSession != null
                                ? (attendedSession == null
                                    ? 'Mark your attendance'
                                    : 'Attendance marked')
                                : 'No active session';
                                */
                            activeSession = null;
                            Column timer = Column(
                              children: <Widget>[
                                Text(
                                  sessionStatus,
                                  style: TextStyle(fontSize: 30),
                                ),
                                Text(
                                    '${duration.inMinutes.remainder(60).toString().padLeft(2, "0")}:${duration.inSeconds.remainder(60).toString().padLeft(2, "0")}',
                                    style: TextStyle(fontSize: 100)),
                              ],
                            );
                            if (activeSessionData.connectionState ==
                                ConnectionState.waiting) {
                            } else if (activeSessionData.hasData &&
                                activeSessionData.data != null) {
                              activeSession = activeSessionData.data!.session;

                              duration = activeSessionData.data!.duration;
                            }
                            try {
                              attendedSession = (activeSession == null)
                                  ? null
                                  : atdSnapshot.data?.docs.firstWhere(
                                      (doc) =>
                                          doc.get('sessionid') ==
                                          activeSession?.id,
                                    );
                            } catch (e) {
                              attendedSession = null;
                            }
                            return timer;
                          }),
                    ]);
              }))
    ]);
  }
}
