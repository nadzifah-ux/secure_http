import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _api = ApiService();

  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _api.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Posts'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final posts = snapshot.data ?? [];

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${post.id}'),
                  ),
                  title: Text(post.title),
                  subtitle: Text(post.body),
                ),
              );
            },
          );
        },
      ),
    );
  }
}