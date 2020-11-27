import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotistats/loading_page.dart';

class MainPage extends StatefulWidget {
  final String client_id;
  final String auth_code;
  MainPage({this.client_id, this.auth_code});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedTimeSpan = 1;
  List topArtists;
  List topSongs;
  String selectedList = "artists";

  List timeSpan = ["short_term", "medium_term", "long_term"];

  void switchTop() {
    if (selectedList == "artists"){
      setState(() {
        selectedList = "tracks";
      });
    } else if (selectedList == "tracks") {
      setState(() {
        selectedList = "artists";
      });
    }
  }

  Color getColor(int index) {
    if (index == 0) {
      return Colors.amber;
    } else {
      return Colors.grey;
    }
  }

  void nextTimeSpan() {
    if (selectedTimeSpan == 2) {
      setState(() {
        selectedTimeSpan = 0;
      });
    } else {
      setState(() {
        selectedTimeSpan++;
      });
    }
  }

  List<Widget> getIcon(int currentSpan) {
    if (currentSpan == 0) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.filter_1),
          onPressed: () {
            nextTimeSpan();
          },
        )
      ];
    } else if (currentSpan == 1) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.filter_2),
          onPressed: () {
            nextTimeSpan();
          },
        )
      ];
    } else if (currentSpan == 2) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.filter_3),
          onPressed: () {
            nextTimeSpan();
          },
        )
      ];
    } else {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () {
            nextTimeSpan();
          },
        )
      ];
    }
  }

  void getData() async {
    List _topArtists = [];
    for (int i = 0; i < 3; i++) {
      var res = await http.get(
          "https://api.spotify.com/v1/me/top/artists?time_range=${timeSpan[i]}",
          headers: {"Authorization": "Bearer ${widget.auth_code}"});
      _topArtists.add(jsonDecode(res.body));
    }

    List _topSongs = [];
    for (int i = 0; i < 3; i++) {
      var res = await http.get(
          "https://api.spotify.com/v1/me/top/tracks?time_range=${timeSpan[i]}",
          headers: {"Authorization": "Bearer ${widget.auth_code}"});
      _topSongs.add(jsonDecode(res.body));
    }

    setState(() {
      topArtists = _topArtists;
      topSongs = _topSongs;
    });
  }

  Widget mainContent() {
    if (selectedList == "artists") {
      return Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
            itemCount: topArtists[selectedTimeSpan].length == null
                ? 0
                : topArtists[selectedTimeSpan].length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                  color: getColor(index),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: 100,
                            height: 100,
                            child: Image.network(topArtists[selectedTimeSpan]
                                ["items"][index]["images"][0]["url"])),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  topArtists[selectedTimeSpan]["items"][index]
                                      ["name"],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                    "Followers: " +
                                        topArtists[selectedTimeSpan]["items"]
                                                [index]["followers"]["total"]
                                            .toString(),
                                    textAlign: TextAlign.left),
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                      "Genres: " +
                                          topArtists[selectedTimeSpan]["items"]
                                                  [index]["genres"]
                                              .toString()
                                              .replaceAll("[", "")
                                              .replaceAll("]", ""),
                                      textAlign: TextAlign.left))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
            }),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
            itemCount: topSongs[selectedTimeSpan].length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                  color: getColor(index),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          child: Image.network(topSongs[selectedTimeSpan]["items"][index]["album"]["images"][0]["url"])),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  topSongs[selectedTimeSpan]["items"][index]
                                      ["name"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(topSongs[selectedTimeSpan]["items"][index]
                                    ["artists"][0]["name"]),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
            }),
      );
    }
  }

  IconData getSwithIcon() {
    if (selectedList == "artists") {
      return Icons.music_note;
    } else if (selectedList == "tracks") {
      return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.auth_code != null && topArtists == null) {
      getData();
    }

    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton(onPressed: switchTop, backgroundColor: Colors.green, child: Icon(getSwithIcon()),),
        appBar: AppBar(
          title: Text("Spotistats"),
          actions: getIcon(selectedTimeSpan),
          backgroundColor: Colors.green,
        ),
        body: topArtists == null ? LoadingContainer() : mainContent());
  }
}
