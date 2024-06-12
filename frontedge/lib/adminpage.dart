import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  // 显示个人信息的组件

  // 显示顶部搜索栏（仅学生可见）

  // 顶部导航栏（仅管理员可见）

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}