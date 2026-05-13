import 'package:flutter/material.dart';
import '../teacher/student_list_screen.dart';

class AllClassesScreen extends StatelessWidget {
  const AllClassesScreen({super.key});

  final List<String> _classes = const [
    'KG', 'Nursery', '1st', '2nd', '3rd', '4th', '5th', 
    '6th', '7th', '8th', '9th', '10th'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Classes')),
      body: ListView.builder(
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Class ${_classes[index]}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentListScreen(className: _classes[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
