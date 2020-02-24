import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:dio/dio.dart';
import 'pattern_info.dart';
import 'color_input.dart';

void main() => runApp(MyApp());

String colorToHexString(Color color) {
  var red = color.red.toRadixString(16).padLeft(2, '0');
  var green = color.green.toRadixString(16).padLeft(2, '0');
  var blue = color.blue.toRadixString(16).padLeft(2, '0');
  return "#$red$green$blue";
}

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
  var client = Dio();
  Future<List<PatternInfo>> availableLightsFuture;
  PatternInfo selectedPattern;
  Color selectedColor = Colors.white;

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
        data: {
          "pattern": selectedPattern.pattern,
          "color": selectedPattern.canChooseColor
              ? colorToHexString(selectedColor)
              : null
        },
        options: Options(contentType: ContentType.json.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PatternInfo>>(
      future: availableLightsFuture,
      builder: (BuildContext context, snapshot) {
        Widget body;

        if (snapshot.hasData) {
          body = Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButton<PatternInfo>(
                  hint: Text("Select a pattern"),
                  value: selectedPattern ?? snapshot.data.first,
                  onChanged: (newValue) {
                    setState(() {
                      selectedPattern = newValue;
                    });
                  },
                  isExpanded: true,
                  underline: Container(
                    height: 2,
                    color: Colors.green,
                  ),
                  items: snapshot.data
                      .map((info) => DropdownMenuItem(
                          value: info,
                          child: Text(
                            info.pattern.titleCase,
                          )))
                      .toList(),
                ),
                ColorInput(
                  color: selectedColor,
                  enabled: selectedPattern?.canChooseColor ?? false,
                  onChanged: (newColor) {
                    setState(() {
                      selectedColor = newColor;
                    });
                  },
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: RaisedButton(
                    child: Text("Set Pattern"),
                    onPressed: selectedPattern != null ? setLightPattern : null,
                  ),
                ),
              ],
            ),
          );
        } else {
          body = LoadingScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    availableLightsFuture = getAvailableLightPatterns();
                    selectedPattern = null;
                    selectedColor = Colors.white;
                  });
                },
              )
            ],
          ),
          body: body,
        );
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
