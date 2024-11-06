// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2022-Present Datadog, Inc.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../custom_card.dart';
import 'rum_dio_instrumentation_second_screen.dart';

class RumDioInstrumentationScenario extends StatefulWidget {
  const RumDioInstrumentationScenario({Key? key}) : super(key: key);

  @override
  State<RumDioInstrumentationScenario> createState() =>
      _RumDioInstrumentationScenarioState();
}

class _RumDioInstrumentationScenarioState
    extends State<RumDioInstrumentationScenario> {
  final dio = Dio();

  final images = [
    'https://picsum.photos/200',
    'https://imgix.datadoghq.com/img/about/presskit/kit/press_kit.png'
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onTap(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(
            name: 'rum_http_second_screen',
          ),
          builder: (_) {
            return RumDioInstrumentationSecondScreen(
              dio: dio,
            );
          },
        ),
      );
    }
  }

  void _sendTraceableLog() async {
    final clientToken = dotenv.get('DD_API_KEY', fallback: '');
    final apiAppKey = dotenv.get('DD_APPLICATION_API_KEY', fallback: '');

    var response = await dio.get(
      'https://api.datadoghq.com/api/v2/logs/events',
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'DD-API-KEY': clientToken,
        'DD-APPLICATION-KEY': apiAppKey,
      }),
    );

    // ignore: avoid_print
    print('Got status response: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto RUM'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < images.length; ++i)
              CustomCard(
                image: images[i],
                text: 'Item $i',
                onTap: () => _onTap(i),
              ),
            ElevatedButton(
              onPressed: _sendTraceableLog,
              child: const Text('Send Traceable Log'),
            ),
          ],
        ),
      ),
    );
  }
}
