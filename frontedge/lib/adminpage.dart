import 'package:flutter/material.dart';
import 'dart:convert';
import 'request.dart';
import 'addstudentinfo.dart';
import 'addborrowinfo.dart';
import 'addreserveinfo.dart';


class AdminPage extends StatefulWidget {
  final String userid;

  // 构造函数
  const AdminPage({Key? key, required this.userid}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState(userid: userid);
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  final String userid; // 存储用户id
  late TabController _tabController; // TabController

  _AdminPageState({required this.userid}); // 构造函数

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 这里设置按钮数量
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(userid),
            centerTitle: true,
            backgroundColor: Colors.blue,
            bottom: const TabBar(
              tabs: [
                Tab(text: '学生信息'),
                Tab(text: '图书借阅'),
                Tab(text: '图书预约'),
              ],
            ),
          ), 
          body: TabBarView(
            children: [
              StudentInfoScreen(userid: userid),
              BorrowRecordsScreen(userid: userid),
              ReserveRecordsScreen(userid: userid),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              switch (DefaultTabController.of(context).index) {
                case 0:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddStudentInfoScreen(student_id: '', student_name: '', login_key: '', student_degree: '本科', student_email: '')));
                  break;
                case 1:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddBorrowInfoScreen(student_id: '', storage_id: '', borrow_date: '', return_date: '')));
                  break;
                case 2:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddReserveInfoScreen(student_id: '', storage_id: '')));
                  break;
              }
            },
            tooltip: '添加新记录',
            child: Icon(Icons.add),
          ),
        );
      })
    );
  }
}

class StudentInfoScreen extends StatelessWidget {
  final String userid;

  StudentInfoScreen({required this.userid});

  Future<List<dynamic>> fetchStudentInfo() async {
    // 返回一个包含学生信息的列表
    Map<String, dynamic> data = jsonDecode(await request(userid, 'get_all_student_info', {}));
    return data['student_info_list'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchStudentInfo(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 显示加载指示器
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // 显示错误信息
          } else {
            List<dynamic> studentInfoList = snapshot.data ?? []; // 获取从后端服务器获取的学生信息列表
            return ListView.builder(
              itemCount: studentInfoList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(studentInfoList[index]['student_name']), 
                  subtitle: Row(
                    children: [
                      Text('学号：${studentInfoList[index]['student_id']}'),
                      SizedBox(width: 10), // 间隔
                      Text('学历：${studentInfoList[index]['student_degree']}'),
                      SizedBox(width: 10),
                      Text('密码：${studentInfoList[index]['login_key']}'),
                      SizedBox(width: 10),
                      Text('邮箱：${studentInfoList[index]['student_email']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          // 修改学生信息
                          // 先将原信息删除
                          Map<String, dynamic> data = jsonDecode(await request(userid, 'delete_student_info', {'student_id': studentInfoList[index]['student_id']}));
                          if (data['status'] != 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('编辑失败')),
                            );
                          }
                          // 再添加新信息
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddStudentInfoScreen(student_id: studentInfoList[index]['student_id'], 
                            student_name: studentInfoList[index]['student_name'], 
                            student_degree: studentInfoList[index]['student_degree'], 
                            student_email: studentInfoList[index]['student_email'], 
                            login_key: studentInfoList[index]['login_key'])));
                        },
                        tooltip: '修改学生信息',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          // 删除学生信息
                          Map<String, dynamic> data = jsonDecode(await request(userid, 'delete_student_info', {'student_id': studentInfoList[index]['student_id']}));
                          if (data['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('删除成功')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('删除失败')),
                            );
                          }
                        },
                        tooltip: '删除学生信息',
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}


class BorrowRecordsScreen extends StatelessWidget {
  final String userid;

  BorrowRecordsScreen({required this.userid});

  Future<List<dynamic>> fetchBorrowInfo() async {
    // 返回一个包含借阅信息的列表
    Map<String, dynamic> data = jsonDecode(await request(userid, 'get_all_borrow_info', {}));
    return data['borrow_info_list'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchBorrowInfo(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 显示加载指示器
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // 显示错误信息
          } else {
            List<dynamic> borrowInfoList = snapshot.data ?? []; // 获取从后端服务器获取的借阅信息列表
            return ListView.builder(
              itemCount: borrowInfoList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(borrowInfoList[index]['book_name']), 
                  subtitle: Row(
                    children: [
                      Text('学号：${borrowInfoList[index]['student_id']}'),
                      SizedBox(width: 10),
                      Text('书号：${borrowInfoList[index]['storage_id']}'),
                      SizedBox(width: 10),
                      Text('借书日期：${borrowInfoList[index]['borrow_date']}'),
                      SizedBox(width: 10),
                      Text('应还日期：${borrowInfoList[index]['return_date']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          // 修改借书信息
                          // 先将原信息删除
                          Map<String, dynamic> data = jsonDecode(await request(userid, 'delete_borrow_info', {'storage_id': borrowInfoList[index]['storage_id']}));
                          if (data['status'] != 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('编辑失败')),
                            );
                          }
                          // 再添加新信息
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddBorrowInfoScreen(student_id: borrowInfoList[index]['student_id'], 
                            storage_id: borrowInfoList[index]['storage_id'], 
                            borrow_date: borrowInfoList[index]['borrow_date'],
                            return_date: borrowInfoList[index]['return_date']))
                          );
                        },
                        tooltip: '修改借书信息',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          // 删除借书信息
                          Map<String, dynamic> data = jsonDecode(await request(userid, 'delete_borrow_info', {'storage_id': borrowInfoList[index]['storage_id']}));
                          if (data['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('删除成功')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('删除失败')),
                            );
                          }
                        },
                        tooltip: '删除借书信息',
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}

class ReserveRecordsScreen extends StatelessWidget {
  final String userid;

  ReserveRecordsScreen({required this.userid});

  Future<List<dynamic>> fetchReserveInfo() async {
    // 返回一个包含预约信息的列表
    Map<String, dynamic> data = jsonDecode(await request(userid, 'get_all_reserve_info', {}));
    return data['reserve_info_list'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchReserveInfo(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 显示加载指示器
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // 显示错误信息
          } else {
            List<dynamic> reserveInfoList = snapshot.data ?? []; // 获取从后端服务器获取的预约信息列表
            return ListView.builder(
              itemCount: reserveInfoList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(reserveInfoList[index]['book_name']), 
                  subtitle: Row(
                    children: [
                      Text('学号：${reserveInfoList[index]['student_id']}'),
                      SizedBox(width: 10),
                      Text('书号：${reserveInfoList[index]['storage_id']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          // 修改预约信息
                          // 先将原信息删除
                          Map<String, dynamic> data = jsonDecode(await request(userid, 'delete_reserve_info', {'storage_id': reserveInfoList[index]['storage_id']}));
                          if (data['status'] != 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('编辑失败')),
                            );
                          }
                          // 再添加新信息
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddReserveInfoScreen(student_id: reserveInfoList[index]['student_id'], 
                            storage_id: reserveInfoList[index]['storage_id']))
                          );
                        },
                        tooltip: '修改预约信息',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          // 删除预约信息
                          Map<String, dynamic> data = jsonDecode(await request(userid, 'delete_reserve_info', {'storage_id': reserveInfoList[index]['storage_id']}));
                          if (data['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('删除成功')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('删除失败')),
                            );
                          }
                        },
                        tooltip: '删除预约信息',
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}