import 'package:flutter/material.dart';
import 'dart:convert';
import 'request.dart';

class StudentPage extends StatefulWidget {
  final String userid;

  // 构造函数
  const StudentPage({Key? key, required this.userid}) : super(key: key);

  @override
  _StudentPageState createState() => _StudentPageState(userid: userid);
}

class UserInfo {
  String name;
  String studentId;

  UserInfo({required this.name, required this.studentId});
}

class SearchResult {
  final String title;
  final String description;

  SearchResult({required this.title, required this.description});
}

class _StudentPageState extends State<StudentPage> {
  final String userid; // 存储用户id
  UserInfo userInfo = UserInfo(name: '', studentId: ''); // 用户信息
  final TextEditingController searchController = TextEditingController();
  List<SearchResult> searchResults = [];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${userInfo.name}'),
                  Text('Student ID: ${userInfo.studentId}'),
                  // 更多基本信息...
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      suffixIcon: IconButton(
                        onPressed: () {
                          searchBook();
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(searchResults[index].title),
                        subtitle: Text(searchResults[index].description),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StudentPageState({required this.userid}){
    // 请求用户信息
    get_user_info();
  }

  Future<void> get_user_info() async{
    Map<String, dynamic> data = jsonDecode(await request(userid, 'get_student_info', {}));
    userInfo.name = data['student_name'];
    userInfo.studentId = data['student_id'];
  }

  Future<void> searchBook() async{
    Map<String, dynamic> data = jsonDecode(await request(userid, 'search_book', {'keyword': searchController.text}));
    searchResults = [];
    for (var item in data['books']) {
      searchResults.add(SearchResult(title: item['title'], description: item['description']));
    }
  }
}