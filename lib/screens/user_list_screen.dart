import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _api = ApiService();

  final TextEditingController _searchController =
      TextEditingController();

  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  // Filter berdasarkan nama atau email
  List<User> get _filteredUsers {
    return _users.where((user) {
      return user.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          user.email
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _api.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari nama atau email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text('Pengguna tidak ditemukan'),
      );
    }

    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.name[0]),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
          ),
        );
      },
    );
  }
}