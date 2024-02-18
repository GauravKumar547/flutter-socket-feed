import 'dart:convert';
import 'dart:html';

import 'package:feed_task/constants/urls.dart';
import 'package:feed_task/models/post_model.dart';
import 'package:feed_task/providers/post_provider.dart';
import 'package:feed_task/screens/detailed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

class FeedItem extends HookConsumerWidget {
  const FeedItem({super.key, required this.data});
  final Post data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likes = useState<List<dynamic>>(data.likes);
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text("Detailed Post"),
                                centerTitle: true,
                                backgroundColor: Colors.green,
                                titleTextStyle: const TextStyle(
                                    color: Colors.white, fontSize: 40),
                              ),
                              body: DetailedPost(postId: data.id),
                            )));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    data.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text(data.description),
                  const Divider(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(likes.value.length.toString()),
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
                                    "post_id": data.id
                                  }))
                              .then((res) {
                            if (res.statusCode != 200) {
                              window.alert("something went wrong");
                            }
                          });
                        },
                        icon: Icon(
                          Icons.thumb_up_rounded,
                          color: likes.value.firstWhere(
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
                    Text(data.comments.length.toString()),
                    const Icon(
                      Icons.message_rounded,
                      color: Colors.grey,
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
