import 'package:flutter/material.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  List users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    List<dynamic> data = await ApiService().getUsers();

    setState(() {
      users = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FastAPI MySQL Example")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                await ApiService().createUser(
                  nameController.text,
                  emailController.text,
                );

                nameController.clear();
                emailController.clear();

                await loadUsers();

                setState(() {
                  emailController.clear();
                  nameController.clear();
                  isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Information Stored Successfully"),
                  ),
                );
              },

              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text("Submit"),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: RefreshIndicator(
                onRefresh: loadUsers,
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        int indexs = index + 1;
                        return Card(
                          child: ListTile(
                            title: Text(users[index]["name"]),
                            subtitle: Text(users[index]["email"]),
                            trailing: Text(indexs.toString()),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
