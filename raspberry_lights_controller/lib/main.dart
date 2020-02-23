import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  var client = Dio();
  Future<List<PatternInfo>> availableLightsFuture;
  PatternInfo selectedPattern;
  Color selectedColor = Colors.white;
  Color pickerColor = Colors.white;

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

  String colorToHexString(Color color) {
    var red = color.red.toRadixString(16);
    var green = color.green.toRadixString(16);
    var blue = color.blue.toRadixString(16);
    return "#$red$green$blue";
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Select a light pattern:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                DropdownButton<PatternInfo>(
                  value: selectedPattern,
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: RaisedButton.icon(
                          onPressed: selectedPattern?.canChooseColor ?? false
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        contentPadding: const EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        content: SingleChildScrollView(
                                          child: ColorPicker(
                                            pickerColor: pickerColor,
                                            onColorChanged: (newColor) {
                                              setState(() {
                                                pickerColor = newColor;
                                              });
                                            },
                                            paletteType: PaletteType.hsl,
                                            enableAlpha: false,
                                            displayThumbColor: true,
                                            showLabel: true,
                                          ),
                                        ),
                                        actions: [
                                          FlatButton(
                                            child: Text("OK"),
                                            onPressed: () {
                                              setState(() {
                                                selectedColor = pickerColor;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              : null,
                          icon: Icon(Icons.palette),
                          label: Text('Choose a color')),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedColor,
                          border: Border.all(color: Colors.black38, width: 3),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        height: 37,
                      ),
                    ),
                  ]),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: RaisedButton(
                    child: Text("Set Pattern"),
                    onPressed: setLightPattern,
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
