import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'db.dart';

class SessionController extends StatefulWidget {
  final QueryDocumentSnapshot teacher;

  SessionController(this.teacher);
  @override
  State<SessionController> createState() => _SessionControllerState();
}

class _SessionControllerState extends State<SessionController> {
  QueryDocumentSnapshot? activeSession;
  int minutes = 10;
  int seconds = 0;
  Duration duration = Duration();

  Future<void> toggleSession() async {
    if (widget.teacher.data() != null) {
      final now = Timestamp.now();

      if (activeSession == null) {
        final end = Timestamp.fromDate(Timestamp.now().toDate().add(
              Duration(minutes: minutes, seconds: seconds),
            ));
        await widget.teacher.reference
            .collection('sessions')
            .add({'start': now, 'end': end});
      } else {
        await activeSession!.reference.update({'end': now});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DB().getActiveSession(widget.teacher),
        builder: (context, activeSessionData) {
          if (activeSessionData.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (activeSessionData.hasData &&
              activeSessionData.data != null) {
            activeSession = activeSessionData.data!.session;
            duration = activeSessionData.data!.duration;
          }

          return Card(
              child: Center(
                  child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(250, 100)),
                  onPressed: () {
                    if (activeSession == null) {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (_) => SizedBox(
                                width: 300,
                                height: 250,
                                child: Row(children: <Widget>[
                                  Expanded(
                                      child: CupertinoPicker(
                                    children: List.generate(
                                        60,
                                        (i) => Text(
                                              '${i}'.padLeft(2, "0"),
                                              style: TextStyle(fontSize: 60),
                                            )),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    itemExtent: 80,
                                    scrollController:
                                        FixedExtentScrollController(
                                            initialItem: minutes),
                                    onSelectedItemChanged: (int value) {
                                      minutes = value;
                                    },
                                  )),
                                  Expanded(
                                      child: CupertinoPicker(
                                    children: List.generate(
                                        60,
                                        (i) => Text(
                                              '${i}'.padLeft(2, "0"),
                                              style: TextStyle(fontSize: 60),
                                            )),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    itemExtent: 80,
                                    scrollController:
                                        FixedExtentScrollController(
                                            initialItem: seconds),
                                    onSelectedItemChanged: (int value) {
                                      seconds = value;
                                    },
                                  )),
                                ]),
                              ));
                    }
                  },
                  child: Text(
                    '${duration.inMinutes.remainder(60).toString().padLeft(2, "0")}:${duration.inSeconds.remainder(60).toString().padLeft(2, "0")}',
                    style: TextStyle(fontSize: 80),
                  )),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: ElevatedButton(
                  child: Icon(
                      (activeSession == null) ? Icons.play_arrow : Icons.stop,
                      size: 40),
                  key: ValueKey<bool>(activeSession != null),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(10), shape: CircleBorder()),
                  onPressed: () async {
                    await toggleSession();
                  },
                ),
              ),
            ]),
          ])));
        });
  }
}
