import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const baseUrl = "http://10.100.241.72:8000";
  static const baseUrl = "https://flutter-fastapi-application.onrender.com";

  Future addTask(String description) async {
    await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"description": description}),
    );
  }

  Future<List> getTasks() async {
    final response = await http.get(Uri.parse("$baseUrl/tasks"));

    return jsonDecode(response.body);
  }

  Future updateTask(int id, String description) async {
    await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"description": description}),
    );
  }

  Future deleteTask(int id) async {
    await http.delete(Uri.parse("$baseUrl/tasks/$id"));
  }
}
