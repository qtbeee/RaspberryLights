import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(),
        Expanded(
          child: Center(child: Text('Fetching available light patterns...')),
        ),
      ],
    );
  }
}
