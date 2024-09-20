import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String serviceAccountContent = await rootBundle.loadString(
      'assets/service_account.json'); //Add your own JSON service account and make sure it is ignored in your version control system

  // Initialize Firebase with the service account content
  await FirebaseApp.initializeAppWithServiceAccount(
    serviceAccountContent: serviceAccountContent,
    serviceAccountKeyFilePath: '',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Admin Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UserManagementScreen(),
    );
  }
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Creating an instance of the SDK
  FirebaseAuth? firebaseAuth;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  String _status = "";

  // Initializing the instance in the initState of the Widget
  @override
  void initState() {
    firebaseAuth = FirebaseApp.firebaseAuth;
    super.initState();
  }

  Future<void> registerNewUser() async {
    try {
      // Using the instance to create a user with email and password with returns [UserCredential] object
      var userCredential = await firebaseAuth?.createUserWithEmailAndPassword(
          _emailController.text, _passwordController.text);

      // Checking whethe the credntial are null or not and later updating the same with the rol
      if (userCredential != null) {
        firebaseAuth?.updateUserInformation(userCredential.user.uid,
            userCredential.user.idToken!, {'role': _roleController.text});
      }

      setState(() {
        _status =
            "User created successfully with role: ${_roleController.text}";
      });
    } catch (e) {
      setState(() {
        _status = "Failed to create user: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // Calling the method on submitting the above information
              onPressed: registerNewUser,
              child: const Text('Create User'),
            ),
            const SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
