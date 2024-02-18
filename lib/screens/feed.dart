import 'dart:convert';

import 'package:feed_task/components/feed_item.dart';
import 'package:feed_task/constants/urls.dart';
import 'package:feed_task/login.dart';
import 'package:feed_task/models/post_model.dart';
import 'package:feed_task/providers/post_provider.dart';
import 'package:feed_task/providers/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Feed extends HookConsumerWidget {
  Feed({super.key, required this.title});
  final String title;
  final postCreateInputController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postProvider);
    final user = ref.watch(userState);
    late IO.Socket socket;
    useEffect(() {
      socket = IO.io('http://localhost:8080', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      socket.on('connect', (_) {
        print('Connected');
      });

      socket.on('updated', (data) {
        try {
          ref.invalidate(postProvider);
        } catch (e) {
          debugPrint(e.toString());
        }
      });
      return () {
        socket.disconnect();
      };
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                storage.clear();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(title: "Login"),
                    ));
              },
              icon: const Icon(Icons.logout)),
        ],
        backgroundColor: Colors.green,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 40),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            SizedBox(
              width: 400,
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your thourghts"),
                controller: postCreateInputController,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                if (postCreateInputController.text.isNotEmpty &&
                    user.id != '') {
                  ref.read(postProvider.notifier).addPost(
                      user.id, user.username, postCreateInputController.text);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5)),
                child: const Text(
                  "Create Post",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) =>
                    FeedItem(key: Key(index.toString()), data: posts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
