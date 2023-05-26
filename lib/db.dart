import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ActiveSessionData {
  final QueryDocumentSnapshot? session;
  Duration duration = Duration();

  ActiveSessionData(this.session, this.duration);
}

class DB {
  Future<QueryDocumentSnapshot?> signIn(
      String classID, String id, String pw) async {
    if (classID.isEmpty) classID = 'none';
    final classRef = FirebaseFirestore.instance.collection(classID);

    final classSnapshot = await classRef.limit(1).get();

    if (classSnapshot.docs.isEmpty) {
      throw Exception('Class ID invalid');
    }

    final query = await classRef.where('id', isEqualTo: id).limit(1).get();

    if (query.docs.isEmpty) {
      throw Exception('ID not found');
    }

    QueryDocumentSnapshot user = query.docs.first;
    if (user['pw'] != pw) {
      throw Exception('Incorrect password');
    }

    await writeUserData(classID, id, pw);

    return user;
  }

  Future<void> writeUserData(String classID, String id, String pw) async {
    await secureWrite('classID', classID);
    await secureWrite('id', id);
    await secureWrite('pw', pw);
  }

  Future<Map<String, String>> getSignInData() async {
    Map<String, String> signInData = {};
    String classID = (await secureRead('classID'));
    String id = (await secureRead('id'));
    String pw = (await secureRead('pw'));
    signInData['classID'] = classID;
    signInData['id'] = id;
    signInData['pw'] = pw;
    return signInData;
  }

  Future<String> secureRead(String key) async {
    return await FlutterSecureStorage().read(key: key) ?? '';
  }

  Future<void> secureWrite(String key, String value) async {
    await FlutterSecureStorage().write(key: key, value: value);
  }

  Stream<ActiveSessionData> getActiveSession(QueryDocumentSnapshot? teacher) {
    Stream<ActiveSessionData> activeSession = Stream.empty();

    if (teacher != null) {
      activeSession =
          Stream.periodic(Duration(milliseconds: 1000), (_) => Timestamp.now())
              .asyncMap((now) async {
        final snapshot = await teacher.reference
            .collection('sessions')
            .orderBy('end')
            .startAt([now])
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          Duration duration =
              snapshot.docs.first.get('end').toDate().difference(now.toDate());
          return ActiveSessionData(snapshot.docs.first, duration);
        } else {
          return ActiveSessionData(null, Duration());
        }
      });
    }
    return activeSession;
  }
}
