import 'package:flutter/material.dart';
import 'studentpage.dart';
import 'adminpage.dart';

class UserAPP extends StatelessWidget {
  const UserAPP({Key? key, required this.userid, required this.is_admin}) : super(key: key);

  final String userid; // 存储用户id
  final bool is_admin; // 标记是否是管理员

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: is_admin ? AdminPage() : StudentPage(userid: userid),
    );
  }
}