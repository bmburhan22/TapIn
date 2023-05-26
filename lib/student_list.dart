import 'student_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentList extends StatefulWidget {
  QueryDocumentSnapshot teacher;
  StudentList(this.teacher);

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  @override
  Widget build(BuildContext context) {
    String classID = widget.teacher.reference.parent.id;
    if (classID.isEmpty) {
      classID = 'none';
    }
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(classID)
            .where('type', isEqualTo: 1)
            .snapshots(),
        builder: (context, studentsSnapshot) {
          List<QueryDocumentSnapshot> students = [];

          if (studentsSnapshot.hasData) {
            students = studentsSnapshot.data!.docs;
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              return StudentCard(students[index], widget.teacher);
            },
          );
        });
  }
}
