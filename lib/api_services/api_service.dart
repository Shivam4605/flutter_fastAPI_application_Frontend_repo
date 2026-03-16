import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  // static const baseUrl = "http://10.100.241.72:8000";
  final String baseUrl = "https://flutter-fastapi-application.onrender.com";

  Future addTask(String description) async {
    http.Response response = await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"description": description}),
    );
    log("$response");
  }

  Future<List> getTasks() async {
    http.Response response = await http.get(Uri.parse("$baseUrl/tasks"));

    return jsonDecode(response.body);
  }

  Future updateTask(int id, String description) async {
    http.Response response = await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"description": description}),
    );
    log("$response");
  }

  Future deleteTask(int id) async {
    http.Response response = await http.delete(Uri.parse("$baseUrl/tasks/$id"));
    log("$response");
  }
}
