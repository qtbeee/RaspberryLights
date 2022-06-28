import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

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
