import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginPage extends StatefulWidget {
  final String client_id;
  LoginPage({this.client_id});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String code;

  // https://stackoverflow.com/a/63433194/14266484
  String getRandomCode(int length) {
    final Random _generator = Random.secure();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(
        length, (index) => _chars[_generator.nextInt(_chars.length)]).join();
  }

  String getAuthUrl() {
    // crypto
    code = getRandomCode(128);
    var digest = sha256.convert(ascii.encode(code));
    String code_challenge = base64Url
        .encode(digest.bytes)
        .replaceAll("=", "")
        .replaceAll("+", "-")
        .replaceAll("/", "_");

    return Uri.parse(
            "https://accounts.spotify.com/authorize?response_type=code&client_id=${widget.client_id}&redirect_uri=http%3A%2F%2Flocalhost%2Fauth&scope=user-top-read&code_challenge=$code_challenge&code_challenge_method=S256")
        .toString();
  }

  void handleAuth(NavigationRequest request) {
    print("URL: ${request.url}");
    Uri.parse(request.url).queryParameters.forEach((key, value) async {
      if (key == "code") {
        var endpoint = "https://accounts.spotify.com/api/token";
        var res = await http.post(endpoint, body: {
          "client_id": widget.client_id,
          "grant_type": "authorization_code",
          "code": value,
          "redirect_uri": "http://localhost/auth",
          "code_verifier": code
        });
        var creds = jsonDecode(res.body);
        Navigator.pop(context, creds);
      } else if (key == "error") {
        Navigator.pop(context, null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.green,
      ),
      body: Builder(
        builder: (BuildContext context) {
          return WebView(
            initialUrl: getAuthUrl(),
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith("http://localhost")) {
                handleAuth(request);
                return NavigationDecision.prevent;
              } else {
                return NavigationDecision.navigate;
              }
            },
          );
        },
      ),
    );
  }
}
