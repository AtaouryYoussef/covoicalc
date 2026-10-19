import 'package:covoitcalc_app/main.dart';
import 'package:covoitcalc_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_page.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Login"),
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                try {
                  // Try to sign in the user with email & password
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  // If login is successful, navigate to DashboardPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => DashboardPage(userEmail: emailController.text),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  String message = "Erreur de connexion";

                  // Handling different login errors
                  if (e.code == 'user-not-found') {
                    message = 'Utilisateur non trouvé';
                  } else if (e.code == 'wrong-password') {
                    message = 'Mot de passe incorrect';
                  }

                  // Show error message
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text("Erreur"),
                          content: Text(message),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                  );
                }
              },
            ),
            TextButton(
              child: Text("Don't have an account? Sign up"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignupPage(),
                  ), // Go to the Signup page
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
