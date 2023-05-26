import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'db.dart';

class StudentCard extends StatefulWidget {
  QueryDocumentSnapshot student, teacher;
  StudentCard(this.student, this.teacher);
  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  QueryDocumentSnapshot? activeSession, attendedSession;
  Future<void> toggleAttendance() async {
    if (attendedSession != null) {
      await attendedSession!.reference.delete();
    } else if (activeSession != null) {
      await widget.student.reference
          .collection('atd')
          .add({'sessionid': activeSession!.id, 'time': Timestamp.now()});
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> toggleAttendance() async {
      if (attendedSession != null) {
        await attendedSession!.reference.delete();
      } else if (activeSession != null) {
        await widget.student.reference
            .collection('atd')
            .add({'sessionid': activeSession!.id, 'time': Timestamp.now()});
      }
    }

    return StreamBuilder<QuerySnapshot>(
        stream: widget.student.reference.collection('atd').snapshots(),
        builder: (context, atdSnapshot) {
          return Card(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                Expanded(
                    child: ListTile(
                        title: Text(widget.student.get('id') ?? '',
                            style: TextStyle(fontSize: 30)))),
                StreamBuilder(
                    stream: DB().getActiveSession(widget.teacher),
                    builder: (context, activeSessionData) {
                      activeSession = null;

                      if (activeSessionData.connectionState ==
                          ConnectionState.waiting) {
                      } else if (activeSessionData.hasData &&
                          activeSessionData.data != null) {
                        activeSession = activeSessionData.data!.session;
                      }
                      try {
                        attendedSession = (activeSession == null)
                            ? null
                            : atdSnapshot.data?.docs.firstWhere(
                                (doc) =>
                                    doc.get('sessionid') == activeSession?.id,
                              );
                      } catch (e) {
                        attendedSession = null;
                      }
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${(atdSnapshot.data?.size ?? 0)}',
                              style: TextStyle(fontSize: 30),
                            ),
                            Switch(
                                value: attendedSession != null,
                                onChanged: (value) async {
                                  await toggleAttendance();
                                })
                          ]);
                    }),
              ]));
        });
  }
}
