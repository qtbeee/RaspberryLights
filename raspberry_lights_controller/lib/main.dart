import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:recase/recase.dart';
import 'package:dio/dio.dart';
import 'pattern_info.dart';
import 'color_input.dart';

void main() => runApp(const MyApp());

String colorToHexString(Color color) {
  var red = color.red.toRadixString(16).padLeft(2, '0');
  var green = color.green.toRadixString(16).padLeft(2, '0');
  var blue = color.blue.toRadixString(16).padLeft(2, '0');
  return "#$red$green$blue";
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lights Controller',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Lights Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var client = Dio();
  late Future<List<PatternInfo>> availableLightsFuture;
  PatternInfo? selectedPattern;
  Color selectedColor = Colors.white;
  int animationSpeed = 1;

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
    } on DioError catch (e) {
      if (kDebugMode) {
        print("error fetching patterns: $e");
      }
      return [];
    }
  }

  void setLightPattern() {
    if (selectedPattern == null) {
      return;
    }

    final data = {
      "pattern": selectedPattern!.pattern,
      "colors": selectedPattern!.canChooseColor
          ? [
              colorToHex(selectedColor,
                  includeHashSign: true, enableAlpha: false)
            ]
          : null,
      "animationSpeed": selectedPattern!.animationSpeeds > 1 ? animationSpeed - 1 : null,
    };

    client.post("pattern",
        data: data, options: Options(contentType: ContentType.json.toString()));
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
                  hint: const Text("Select a pattern"),
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
                  items: snapshot.data!
                      .map((info) => DropdownMenuItem(
                          value: info,
                          child: Text(
                            info.pattern.titleCase,
                          )))
                      .toList(),
                ),
                if (selectedPattern != null &&
                    selectedPattern!.animationSpeeds > 1) ...[
                  const Text('Speed:'),
                  Slider(
                    min: 1,
                    max: selectedPattern!.animationSpeeds.toDouble(),
                    label: '${animationSpeed}',
                    value: animationSpeed.toDouble(),
                    divisions: selectedPattern!.animationSpeeds - 1,
                    onChanged: (value) {
                      setState(() {
                        animationSpeed = value.toInt();
                      });
                    },
                  ),
                ],
                if (selectedPattern?.canChooseColor ?? false)
                  ColorInput(
                    color: selectedColor,
                    enabled: selectedPattern?.canChooseColor ?? false,
                    onChanged: (newColor) {
                      setState(() {
                        selectedColor = newColor;
                      });
                    },
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    child: const Text("Set Pattern"),
                    onPressed: selectedPattern != null ? setLightPattern : null,
                  ),
                ),
              ],
            ),
          );
        } else {
          body = const LoadingScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
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
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        LinearProgressIndicator(),
        Expanded(
          child: Center(child: Text('Fetching available light patterns...')),
        )
      ],
    );
  }
}
