import 'dart:convert';

import 'package:feed_task/constants/urls.dart';
import 'package:feed_task/models/post_model.dart';
import 'package:feed_task/models/user_model.dart';
import 'package:feed_task/providers/storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final userState = StateProvider((ref) => storage['user'] != null
    ? User.fromJson(jsonDecode(storage['user']!))
    : User(id: "", username: ""));
final lastUpdatedPost = StateProvider<Post?>((ref) => null);
final postProvider = StateNotifierProvider<PostNotifier, List<Post>>((ref) {
  return PostNotifier(ref);
});

class PostNotifier extends StateNotifier<List<Post>> {
  PostNotifier(this.ref) : super([]) {
    getPosts();
  }
  final Ref ref;
  getPosts() {
    http.get(
      Uri.parse('$URL/feed'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((res) {
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        List<Post> posts = [];
        for (var post in responseData['posts']) {
          posts.add(Post.fromJson(post));
        }
        state = posts;
      }
    });
  }

  addPost(String userid, String username, String desc) {
    http
        .post(
      Uri.parse('$URL/post'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'description': desc,
        'user_id': userid,
        'username': username
      }),
    )
        .then((res) {
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        state = [Post.fromJson(responseData["post"]), ...state];
      }
    });
  }
}
