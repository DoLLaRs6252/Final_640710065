import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:final_640710065/helpers/api_caller.dart';
import 'package:final_640710065/helpers/my_list_tile.dart';
import 'package:final_640710065/models/todo_item.dart';
import 'package:final_640710065/helpers/my_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoItem> _items = [];
  late int _selectedItemIndex = -1; // Track index of the selected item
  TextEditingController _firstTextFieldController = TextEditingController();
  TextEditingController _secondTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiCaller = ApiCaller();
    try {
      final response = await apiCaller.get('api/2_2566/final/web_types');
      List<dynamic> jsonResponse = json.decode(response);
      List<TodoItem> tempList =
          jsonResponse.map((e) => TodoItem.fromJson(e)).toList();
      setState(() {
        _items = tempList;
      });
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  Future<void> postData() async {
    if (_selectedItemIndex == -1) {
      // No item selected, return early
      return;
    }

    final selectedItemId = _items[_selectedItemIndex].id;
    final url = _firstTextFieldController.text;
    final details = _secondTextFieldController.text;

    final Map<String, dynamic> postData = {
      'URL': url,
      'รายละเอียด': details,
      'id': selectedItemId,
    };

    try {
      final apiCaller = ApiCaller();
      final response = await apiCaller.post('api/2_2566/final/report_web', params: postData);
      print('Post response: $response');
      
      // Optional: Display a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data posted successfully!'),
      ));
    } catch (e) {
      // Handle errors
      print('Failed to post data: $e');
      // Optional: Display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to post data: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Color(0xFFE6F0EF),
      appBar: AppBar(
        backgroundColor: Color(0xFF006A60),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Webby Fondue',
              style: TextStyle(
                color: Colors.white, // กำหนดสีของข้อความเป็นสีขาว
              ),
            ),
            Text(
              'ระบบรายงานเว็บเลวๆ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12, // ขนาดของข้อความ
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  child: Text("*ต้องกรอกข้อมูล"),
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: _firstTextFieldController,
                  hintText: 'URL *',
                ),
                SizedBox(height: 20), // Add some spacing between text fields
                MyTextField(
                  controller: _secondTextFieldController,
                  hintText: 'รายละเอียด',
                ),
                SizedBox(height: 20),
                Container(
                  child: Text("*ระบุประเภทเว็บเลว"),
                ),
                SizedBox(height: 20), // Add some spacing between text fields
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        child: MyListTile(
                          title: item.title,
                          subtitle: item.subtitle,
                          imageUrl: item.image,
                          selected: index ==
                              _selectedItemIndex, // Check if current item is selected
                          onTap: () {
                            setState(() {
                              if (_selectedItemIndex == index) {
                                // If the tapped item is already selected, deselect it
                                _selectedItemIndex = -1;
                              } else {
                                _selectedItemIndex =
                                    index; // Update the selected index
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    postData();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF006A60),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'ส่งข้อมูล',
                    style: TextStyle(
                      color: Colors.white, // กำหนดสีของข้อความเป็นสีขาว
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}
