import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdaptiveLogin extends StatefulWidget {
  final Function(GoogleSignInAccount?) onLogin;

  const AdaptiveLogin({super.key, required this.onLogin});

  @override
  State<AdaptiveLogin> createState() => _AdaptiveLoginState();
}

class _AdaptiveLoginState extends State<AdaptiveLogin> {
  late GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/youtube.readonly',
      ],
      clientId: kIsWeb
          ? 'TU_CLIENT_ID_WEB.apps.googleusercontent.com'
          : null, // Solo necesario para Web/macOS
    );

    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
      widget.onLogin(account);
    });

    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      debugPrint('❌ Error al iniciar sesión: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
    widget.onLogin(null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentUser != null) {
      return _buildLoggedIn();
    } else {
      return _buildLoginButton();
    }
  }

  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _handleSignIn,
        icon: const Icon(Icons.login),
        label: const Text('Iniciar sesión con Google'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLoggedIn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(_currentUser!.photoUrl ?? ''),
        ),
        const SizedBox(height: 10),
        Text(
          _currentUser!.displayName ?? 'Usuario',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(_currentUser!.email),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _handleSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
