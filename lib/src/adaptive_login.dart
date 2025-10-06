import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

import 'app_state.dart';

// ==================== CLIENTE HTTP AUTENTICADO ====================
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

// ==================== LOGIN ADAPTATIVO ====================
typedef _AdaptiveLoginButtonWidget = Widget Function({
  required VoidCallback? onPressed,
});

class AdaptiveLogin extends StatelessWidget {
  const AdaptiveLogin({
    super.key,
    required this.clientId,
    required this.scopes,
    required this.loginButtonChild,
  });

  final ClientId clientId;
  final List<String> scopes;
  final Widget loginButtonChild;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      return _GoogleSignInLogin(
        button: _loginButton,
        scopes: scopes,
      );
    } else {
      return _GoogleApisAuthLogin(
        button: _loginButton,
        scopes: scopes,
        clientId: clientId,
      );
    }
  }

  Widget _loginButton({required VoidCallback? onPressed}) => ElevatedButton(
        onPressed: onPressed,
        child: loginButtonChild,
      );
}

// ==================== LOGIN CON GOOGLE SIGN-IN ====================
class _GoogleSignInLogin extends StatefulWidget {
  const _GoogleSignInLogin({
    required this.button,
    required this.scopes,
  });

  final _AdaptiveLoginButtonWidget button;
  final List<String> scopes;

  @override
  State<_GoogleSignInLogin> createState() => _GoogleSignInLoginState();
}

class _GoogleSignInLoginState extends State<_GoogleSignInLogin> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();

    // Escucha cambios en el usuario actual
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      setState(() => _currentUser = account);

      if (account != null) {
        final headers = await account.authHeaders;
        final authClient = GoogleAuthClient(headers);

        if (mounted) {
          context.read<AuthedUserPlaylists>().authClient = authClient;
          context.go('/');
        }
      }
    });

    // Inicia sesión en silencio si es posible
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      debugPrint('Error al iniciar sesión con Google: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.button(onPressed: _handleSignIn),
      ),
    );
  }
}

// ==================== LOGIN CON GOOGLE APIS AUTH ====================
class _GoogleApisAuthLogin extends StatefulWidget {
  const _GoogleApisAuthLogin({
    required this.button,
    required this.scopes,
    required this.clientId,
  });

  final _AdaptiveLoginButtonWidget button;
  final List<String> scopes;
  final ClientId clientId;

  @override
  State<_GoogleApisAuthLogin> createState() => _GoogleApisAuthLoginState();
}

class _GoogleApisAuthLoginState extends State<_GoogleApisAuthLogin> {
  Uri? _authUrl;

  @override
  void initState() {
    super.initState();

    // Flujo OAuth completo para escritorios o entornos no móviles
    clientViaUserConsent(widget.clientId, widget.scopes, (url) {
      if (mounted) {
        setState(() {
          _authUrl = Uri.parse(url);
        });
      }
    }).then((authClient) {
      if (mounted) {
        context.read<AuthedUserPlaylists>().authClient = authClient;
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUrl = _authUrl;
    if (authUrl != null) {
      return Scaffold(
        body: Center(
          child: Link(
            uri: authUrl,
            builder: (context, followLink) =>
                widget.button(onPressed: followLink),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
