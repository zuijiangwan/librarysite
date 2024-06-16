import 'dart:convert';
import 'package:flutter/material.dart';
import 'request.dart';

class AddStudentInfoScreen extends StatefulWidget {
  final List<String> educationLevels = ['本科', '硕士', '博士'];
  AddStudentInfoScreen({required this.student_id, 
    required this.student_name, 
    required this.login_key, 
    required this.student_degree, 
    required this.student_email});

  final String student_id;
  final String student_name;
  final String login_key;
  final String student_degree;
  final String student_email;

  @override
  _AddStudentInfoScreenState createState() => _AddStudentInfoScreenState(student_id: student_id, 
    student_name: student_name, 
    login_key: login_key, 
    student_degree: student_degree, 
    student_email: student_email);
}

class _AddStudentInfoScreenState extends State<AddStudentInfoScreen> {
  final String student_id;
  final String student_name;
  final String login_key;
  final String student_degree;
  final String student_email;

  _AddStudentInfoScreenState({required this.student_id, 
    required this.student_name, 
    required this.login_key, 
    required this.student_degree, 
    required this.student_email});

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController studentEmailController = TextEditingController();
  final TextEditingController loginKeyController = TextEditingController();
  String selectedEducationLevel = '';

  @override
  Widget build(BuildContext context) {
    // 设置初始内容
    studentIdController.text = student_id;
    studentNameController.text = student_name;
    loginKeyController.text = login_key;
    studentEmailController.text = student_email;
    selectedEducationLevel = student_degree;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑学生信息'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: '学号',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: studentNameController,
              decoration: const InputDecoration(
                labelText: '学生姓名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: loginKeyController,
              decoration: const InputDecoration(
                labelText: '登录密码',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedEducationLevel,
              onChanged: (String? newValue) {
                //setState(() {
                  selectedEducationLevel = newValue!;
                //});
              },
              items: const [
                DropdownMenuItem<String>(
                  value: '本科',
                  child: Text('本科'),
                ),
                DropdownMenuItem<String>(
                  value: '硕士',
                  child: Text('硕士'),
                ),
                DropdownMenuItem<String>(
                  value: '博士',
                  child: Text('博士'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: '学历',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: studentEmailController,
              decoration: const InputDecoration(
                labelText: '校内邮箱',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async { 
                // 向后端发送填写的数据
                Map<String, dynamic> data = jsonDecode(await request('admin', 'new_student_info', 
                  {'student_id': studentIdController.text,
                  'student_name': studentNameController.text,
                  'login_key': loginKeyController.text,
                  'student_degree': selectedEducationLevel,
                  'student_email': studentEmailController.text}));

                // 调试，打印送给后端的结果
                print(studentIdController.text);
                print(studentNameController.text);
                print(loginKeyController.text);
                print(selectedEducationLevel);
                print(studentEmailController.text);

                bool addStatus = data['status'] == 'success';
                if(addStatus){
                  // 添加成功，跳转回原页面
                  Navigator.pop(context);
                } else {
                  // 添加失败
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('添加失败')));
                }
              },
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}