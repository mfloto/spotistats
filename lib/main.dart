import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotistats/loading_page.dart';
import 'package:spotistats/login_page.dart';
import 'main_page.dart';

const String clientID = "<CLIENT_ID>";

void saveToPrefs(String key, String content) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, content);
}

void main() {
  runApp(MaterialApp(home: EntryPage()));
}

class EntryPage extends StatefulWidget {
  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  String auth_code;

  @override
  void initState() {
    super.initState();
    login();
  }

  Future<String> refreshCreds(String refresh_token, String clientID) async {
    String endpoint = "https://accounts.spotify.com/api/token";
    var res = await http.post(endpoint, body: {
      "grant_type": "refresh_token",
      "refresh_token": refresh_token,
      "client_id": clientID
    });
    var creds = jsonDecode(res.body);
    saveToPrefs("refresh_token", creds["refresh_token"]);
    return creds["access_token"];
  }

  void login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("refresh_token")) {
      final res = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage(
                    client_id: clientID,
                  )));
      if (res != null) {
        saveToPrefs("refresh_token", res["refresh_token"]);
        setState(() {
          auth_code = res["access_token"];
        });
      }
    } else {
      String refresh_token = prefs.getString("refresh_token");
      String new_auth_code = await refreshCreds(refresh_token, clientID);
      setState(() {
        auth_code = new_auth_code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return MainPage(
        client_id: clientID,
        auth_code: auth_code,
      );
  }
}
