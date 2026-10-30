import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';
import 'user_list_screen.dart';
import 'post_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _storage = SecureStorageService();
  final ApiService _api = ApiService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    final token = await _storage.getToken();

    if (!mounted) return;

    setState(() {
      _isLoggedIn = token != null;
      _isChecking = false;
    });
  }

  // LATIHAN 1: LOGIN
  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage('Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _api.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      await _storage.saveToken(token);

      if (!mounted) return;

      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });

      _passwordController.clear();
      _showMessage('Login berhasil, token tersimpan');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(e.toString());
    }
  }

  // LATIHAN 2: LOGOUT
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.deleteToken();

      if (!mounted) return;

      setState(() {
        _isLoggedIn = false;
      });

      _showMessage('Logout berhasil');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage & HTTP'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoggedIn)
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: _isLoggedIn ? _homePage() : _loginPage(),
    );
  }

  Widget _loginPage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock,
                  size: 60,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 15),
                const Text(
                  'LOGIN PENGGUNA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.password),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('LOGIN'),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Login simulasi sesuai modul praktikum.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _homePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 35,
            ),
            title: const Text('Login Berhasil'),
            subtitle: const Text('Token tersimpan di secure storage'),
            trailing: IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HTTP REQUEST',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('Daftar Pengguna'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.article),
                    label: const Text('Daftar Posts'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
