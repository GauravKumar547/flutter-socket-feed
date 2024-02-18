import 'dart:convert';
import 'dart:html';

import 'package:feed_task/constants/urls.dart';
import 'package:feed_task/models/post_model.dart';
import 'package:feed_task/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

class DetailedPost extends HookConsumerWidget {
  DetailedPost({super.key, required this.postId});
  final String postId;
  final commentInputController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postProvider);
    final post = useState<Post>(Post(
        userId: "",
        username: "",
        description: "",
        likes: [],
        id: "",
        comments: []));
    post.value = posts.firstWhere(
      (element) => element.id == postId,
      orElse: () => Post(
          userId: "",
          username: "",
          description: "",
          likes: [],
          id: "",
          comments: []),
    );
    final user = ref.watch(userState);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.value.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(post.value.description),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(post.value.likes.length.toString()),
                    IconButton(
                        onPressed: () {
                          http
                              .put(Uri.parse('$URL/like'),
                                  headers: <String, String>{
                                    'Content-Type':
                                        'application/json; charset=UTF-8',
                                  },
                                  body: jsonEncode(<String, String>{
                                    "user_id": user.id,
                                    "post_id": post.value.id
                                  }))
                              .then((res) {
                            if (res.statusCode != 200) {
                              window.alert("something went wrong");
                            }
                          });
                        },
                        icon: Icon(
                          Icons.thumb_up_rounded,
                          color: post.value.likes.firstWhere(
                                    (element) => element == user.id,
                                    orElse: () => -1,
                                  ) !=
                                  -1
                              ? Colors.blue
                              : Colors.grey,
                        ))
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(post.value.comments.length.toString()),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.message_rounded,
                          color: Colors.grey,
                        ))
                  ],
                )
              ],
            ),
            const Divider(),
            const Text(
              "Comments",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter your thourghts"),
                    controller: commentInputController,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      if (commentInputController.text.isNotEmpty) {
                        http
                            .put(Uri.parse('$URL/comment'),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                },
                                body: jsonEncode(<String, dynamic>{
                                  "user_id": user.id,
                                  "post_id": post.value.id,
                                  "comment": {
                                    "user_id": user.id,
                                    "username": user.username,
                                    "comment": commentInputController.text
                                  }
                                }))
                            .then((res) {
                          if (res.statusCode != 200) {
                            window.alert("something went wrong");
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
            Expanded(
                child: ListView.builder(
              itemCount: post.value.comments.length,
              itemBuilder: (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.value.comments[index]["username"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(post.value.comments[index]["comment"]),
                    const Divider()
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
    ;
  }
}
