import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:dio/dio.dart';
import './pattern_info.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lights Controller',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Lights Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final uriBase = "192.168.0.199:5000";
  var client = Dio();
  Future<List<PatternInfo>> availableLightsFuture;
  PatternInfo selectedPattern;
  Color selectedColor;

  @override
  void initState() {
    client.options.baseUrl = "http://192.168.0.199:5000/";
    client.options.responseType = ResponseType.json;
    availableLightsFuture = getAvailableLightPatterns();
    super.initState();
  }

  Future<List<PatternInfo>> getAvailableLightPatterns() async {
    try {
      var response = await client.get("pattern");
      return List.from(response.data['patterns'])
          .map((v) => PatternInfo.fromJson(v))
          .toList();
    } on DioError {
      return [];
    }
  }

  void setLightPattern() {
    client.post("pattern",
        data: {"pattern": selectedPattern.pattern, "color": selectedColor},
        options: Options(contentType: ContentType.json.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PatternInfo>>(
      future: availableLightsFuture,
      builder: (BuildContext context, snapshot) {
        Widget body;

        if (snapshot.hasData) {
          body = Column(children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Select a light pattern:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Flexible(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var patternInfo = snapshot.data[index];
                    return RadioListTile(
                        title: Text(patternInfo.pattern.sentenceCase),
                        subtitle: Text(
                            "canChooseColor: ${patternInfo.canChooseColor}"),
                        value: patternInfo,
                        groupValue: selectedPattern,
                        onChanged: (value) => setState(() {
                              selectedPattern = value;
                            }));
                  }),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: RaisedButton(
                child: Text("Set Pattern"),
                onPressed: setLightPattern,
              ),
            ),
          ]);
        } else {
          body = LoadingScreen();
        }

        return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: body);
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(),
        const Expanded(
          child: Center(child: Text('Fetching available light patterns...')),
        )
      ],
    );
  }
}
