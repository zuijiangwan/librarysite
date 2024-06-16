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

class _StudentPageState extends State<StudentPage> {
  final String userid; // 存储用户id
  final TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userid),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search books',
                      suffixIcon: IconButton(
                        onPressed: () async {
                          Map<String, dynamic> data = jsonDecode(await request(userid, 'search_book', {'keyword': searchController.text}));
                          setState(() {
                            searchResults = data['storage_info_list'];
                          });
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
                        leading: Image.network(
                          "http://127.0.0.1:8000/static${searchResults[index]['storage_cover']}",
                          width: 100.0,
                        ),
                        title: Text(searchResults[index]['book_name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('作者: ${searchResults[index]['book_author']}'),
                            Text('书号: ${searchResults[index]['book_id']}'),
                            Text('出版社: ${searchResults[index]['storage_publish']}'),
                            Text('出版时间: ${searchResults[index]['storage_publish_time']}'),
                            Text(searchResults[index]['storage_status'] == true ? '状态：外借' : '状态：在馆'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (searchResults[index]['storage_state'] == 'False') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('该书在馆，可直接借阅')));
                              return;
                            }
                            request(userid, 'reserve_book', {'student_id': userid,'storage_id': searchResults[index]['storage_id']}).then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
                            });
                          },
                          child: Text('预约'),
                        ),
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

  _StudentPageState({required this.userid});
}