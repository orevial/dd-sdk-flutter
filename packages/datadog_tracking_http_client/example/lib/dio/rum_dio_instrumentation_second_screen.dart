// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2022-Present Datadog, Inc.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../scenario_config.dart';
import 'rum_dio_instrumentation_third_screen.dart';

class RumDioInstrumentationSecondScreen extends StatefulWidget {
  final Dio dio;

  const RumDioInstrumentationSecondScreen({Key? key, required this.dio})
      : super(key: key);

  @override
  State<RumDioInstrumentationSecondScreen> createState() =>
      _RumDioInstrumentationSecondScreenState();
}

class _RumDioInstrumentationSecondScreenState
    extends State<RumDioInstrumentationSecondScreen> {
  late Future _loadingFuture;
  late RumAutoInstrumentationScenarioConfig _config;
  var _currentStatus = 'Starting fetch';

  @override
  void initState() {
    super.initState();
    _config = RumAutoInstrumentationScenarioConfig.instance;
    _loadingFuture = _fetchResources();
  }

  Future<void> _fetchResources() async {
    // First Party Hosts
    await widget.dio.get(_config.firstPartyGetUrl);
    if (_config.firstPartyPostUrl != null) {
      setState(() {
        _currentStatus = 'Post First Party';
      });
      await widget.dio.post(_config.firstPartyPostUrl!);
    }

    setState(() {
      _currentStatus = 'Get First Party - Bad Request';
    });
    try {
      await widget.dio.get(_config.firstPartyBadUrl);
    } catch (e) {
      // ignore: avoid_print
      print('Request failed: $e');
    }

    setState(() {
      _currentStatus = 'Third party get';
    });
    await widget.dio.get(_config.thirdPartyGetUrl);

    setState(() {
      _currentStatus = 'Third party post';
    });
    await widget.dio.post(_config.thirdPartyPostUrl);
  }

  Widget _buildLoaded() {
    return Center(
      child: Column(
        children: [
          const Text('All Done'),
          ElevatedButton(
            onPressed: _onNext,
            child: const Text('Next Page'),
          ),
        ],
      ),
    );
  }

  void _onNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'rum_http_third_screen'),
        builder: (_) => const RumDioInstrumentationThirdScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secondary Screen'),
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? _buildLoaded()
              : Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      Text(_currentStatus),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
