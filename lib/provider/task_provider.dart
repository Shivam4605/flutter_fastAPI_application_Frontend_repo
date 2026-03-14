import 'package:fast_api_and_flutter/api_services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  ApiService apiService = ApiService();

  List<Task> tasks = [];

  Future fetchTasks() async {
    final data = await apiService.getTasks();

    tasks = data.map<Task>((e) => Task.fromJson(e)).toList();

    notifyListeners();
  }

  Future addTask(String description) async {
    await apiService.addTask(description);

    await fetchTasks();
  }

  Future updateTask(int id, String description) async {
    await apiService.updateTask(id, description);

    await fetchTasks();
  }

  Future deleteTask(int id) async {
    await apiService.deleteTask(id);

    await fetchTasks();
  }
}
