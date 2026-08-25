import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const VedaParentApp());
}

class VedaParentApp extends StatelessWidget {
  const VedaParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ڤيدا - تطبيق أولياء الأمور',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const ParentDashboardScreen(),
    );
  }
}

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  // رابط السيرفر (يتم تغييره لرابط السيرفر النهائي)
  final String baseUrl = "http://127.0.0.1:8000"; 
  int studentId = 1;
  List grades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/grades/student/$studentId'));
      if (response.statusCode == 200) {
        setState(() {
          grades = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📱 تطبيق ولي الأمر - ڤيدا'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchStudentData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                style: const TextStyle(fontSize: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📊 سجل درجات الطالب الحالية:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: grades.isEmpty
                          ? const Center(child: Text("لا توجد درجات مسجلة حالياً"))
                          : ListView.builder(
                              itemCount: grades.length,
                              itemBuilder: (context, index) {
                                final item = grades[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.star, color: Colors.amber),
                                    title: Text("المادة: ${item['subject_name']}"),
                                    subtitle: Text("الامتحان: ${item['exam_type']}"),
                                    trailing: Text(
                                      "${item['score']}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
