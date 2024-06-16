import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'request.dart';

class AddBorrowInfoScreen extends StatefulWidget {
  AddBorrowInfoScreen({required this.student_id, 
    required this.storage_id, 
    required this.borrow_date, 
    required this.return_date});

  final String student_id;
  final String storage_id;
  final String borrow_date;
  final String return_date;

  @override
  _AddBorrowInfoScreenState createState() => _AddBorrowInfoScreenState(student_id: student_id, 
    storage_id: storage_id, 
    borrow_date: borrow_date,
    return_date: return_date);
}

class _AddBorrowInfoScreenState extends State<AddBorrowInfoScreen> {
  final String student_id; // 学号
  final String storage_id; // 书号
  final String borrow_date; // 借书日期
  final String return_date; // 应还日期

  _AddBorrowInfoScreenState({required this.student_id, 
    required this.storage_id, 
    required this.borrow_date, 
    required this.return_date});

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController storageIdController = TextEditingController();
  DateTime borrowDate = DateTime.now();
  DateTime returnDate = DateTime.now().add(Duration(days: 15));

  @override
  Widget build(BuildContext context) {
    // 设置初始内容
    studentIdController.text = student_id;
    storageIdController.text = storage_id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑借阅信息'),
        backgroundColor: Colors.blue,
      ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: studentIdController,
              decoration: InputDecoration(
                labelText: '学号',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: storageIdController,
              decoration: InputDecoration(
                labelText: '书号',
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('借书日期: ${DateFormat('yyyy-MM-dd').format(borrowDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: borrowDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != borrowDate) {
                  setState(() {
                    borrowDate = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text('应还日期: ${DateFormat('yyyy-MM-dd').format(returnDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: returnDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != returnDate) {
                  setState(() {
                    returnDate = picked;
                  });
                }
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // 向后端发送填写的数据
                Map<String, dynamic> data = jsonDecode(await request('admin', 'new_borrow_info', {
                  'student_id': studentIdController.text,
                  'storage_id': storageIdController.text,
                  'borrow_date': DateFormat('yyyy-MM-dd').format(borrowDate),
                  'return_date': DateFormat('yyyy-MM-dd').format(returnDate),
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