import 'dart:convert';

import 'package:feed_task/constants/urls.dart';
import 'package:feed_task/models/user_model.dart';
import 'package:feed_task/providers/post_provider.dart';
import 'package:feed_task/providers/storage.dart';
import 'package:feed_task/screens/feed.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;

class Login extends HookConsumerWidget {
  Login({super.key, required this.title});
  final String title;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.green,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 40),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("username: "),
                SizedBox(
                  width: 30.w,
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter your username"),
                    controller: usernameController,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("password: "),
                SizedBox(
                  width: 30.w,
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter your password"),
                    controller: passwordController,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: () {
                if (usernameController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  http
                      .post(
                    Uri.parse('$URL/login'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'username': usernameController.text,
                      'password': passwordController.text,
                    }),
                  )
                      .then((res) {
                    if (res.statusCode == 200) {
                      final Map<String, dynamic> responseData =
                          jsonDecode(res.body);
                      ref.read(userState.notifier).state =
                          User.fromJson(responseData);
                      storage['user'] = res.body.toString();
                      storage['loggedin'] = "true";
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Feed(title: "My Feed"),
                          ));
                    }
                  }).catchError((err) {
                    debugPrint(err);
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5)),
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
