
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/post.dart';

class ApiService {
  static const String _baseUrl =
      'https://jsonplaceholder.typicode.com';

  static const Duration _defaultTimeout =
      Duration(seconds: 10);

  // GET /users dengan timeout yang bisa diatur
  Future<List<User>> getUsers({
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      print('Request GET: $_baseUrl/users');

      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat data. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception(
        'Request timeout setelah ${timeout.inSeconds} detik',
      );
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } on FormatException {
      throw Exception('Format data tidak valid.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // GET /users/{id}
  Future<User> getUserById(int id) async {
    try {
      print('Request GET: $_baseUrl/users/$id');

      final response = await http
          .get(Uri.parse('$_baseUrl/users/$id'))
          .timeout(_defaultTimeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        return User.fromJson(data);
      } else {
        throw Exception(
          'Gagal memuat data. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Simulasi login
  Future<String> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (email.isNotEmpty && password.isNotEmpty) {
        final token =
            'dummy_token_${DateTime.now().millisecondsSinceEpoch}';

        print('Login berhasil untuk email: $email');

        return token;
      } else {
        throw Exception(
          'Email dan password tidak boleh kosong',
        );
      }
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  // GET /posts
  Future<List<Post>> getPosts() async {
    try {
      print('Request GET: $_baseUrl/posts');

      final response = await http
          .get(Uri.parse('$_baseUrl/posts'))
          .timeout(_defaultTimeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((json) => Post.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat posts. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } on FormatException {
      throw Exception('Format data tidak valid.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
