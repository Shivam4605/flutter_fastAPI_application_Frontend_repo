import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  Future createUser(String name, String email) async {
    String endPoint = "create_user";
    String url = "http://10.100.241.72:8000/$endPoint";
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email}),
      );

      log("Status code: ${response.statusCode}");
      log("body: ${response.body}");
    } catch (e) {
      log("API error: $e");
    }
  }

  Future<List<dynamic>> getUsers() async {
    String endPoint = "get_users";
    String url = "http://10.100.241.72:8000/$endPoint";
    Uri uri = Uri.parse(url);

    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load users");
    }
  }
}
