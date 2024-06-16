import 'dart:convert';
import 'package:flutter/material.dart';
import 'request.dart';

class AddReserveInfoScreen extends StatefulWidget {
  AddReserveInfoScreen({required this.student_id, required this.storage_id});

  final String student_id;
  final String storage_id;

  @override
  _AddReserveInfoScreenState createState() => _AddReserveInfoScreenState(student_id: student_id, storage_id: storage_id);
}

class _AddReserveInfoScreenState extends State<AddReserveInfoScreen> {
  final String student_id; // 学号
  final String storage_id; // 书号

  _AddReserveInfoScreenState({required this.student_id, required this.storage_id});

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController storageIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 设置初始内容
    studentIdController.text = student_id;
    storageIdController.text = storage_id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑预约信息'),
        backgroundColor: Colors.blue,
      ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: '学号',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: storageIdController,
              decoration: const InputDecoration(
                labelText: '书号',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // 向后端发送填写的数据
                Map<String, dynamic> data = jsonDecode(await request('admin', 'new_reserve_info', {
                  'student_id': studentIdController.text,
                  'storage_id': storageIdController.text,
                }));
                if (data['status'] == 'success') {
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('错误'),
                        content: Text(data['message']),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}