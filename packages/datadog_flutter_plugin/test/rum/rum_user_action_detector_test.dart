// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2019-Present Datadog, Inc.

import 'package:datadog_common_test/datadog_common_test.dart';
import 'package:datadog_flutter_plugin/src/rum/ddrum.dart';
import 'package:datadog_flutter_plugin/src/rum/rum_user_action_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDdRum extends Mock implements DatadogRum {}

Widget _testWidgetBuilder(Widget? child) {
  return SizedBox.square(
    dimension: 5,
    child: Container(
      color: Colors.white,
      child: child,
    ),
  );
}

class _DescriptiveWidget extends StatelessWidget {
  final Widget? child;

  const _DescriptiveWidget({this.child});

  @override
  Widget build(BuildContext context) {
    return _testWidgetBuilder(child);
  }
}

class _VagueWidget extends StatelessWidget {
  final Widget? child;

  const _VagueWidget({this.child});

  @override
  Widget build(BuildContext context) {
    return _testWidgetBuilder(child);
  }
}

Widget _buildSimpleApp(DatadogRum rum, Widget innerWidget) {
  return RumUserActionDetector(
    rum: rum,
    customGestureDetector: (widget) {
      if (widget is _DescriptiveWidget) {
        return RumGestureDetectorInfo(
          'DescriptiveWidget',
          searchForText: false,
          searchForBetter: false,
        );
      } else if (widget is _VagueWidget) {
        return RumGestureDetectorInfo(
          'VagueWidget',
          searchForBetter: true,
          searchForText: true,
        );
      }
      return null;
    },
    child: MaterialApp(
      color: Colors.blueAccent,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Bar Title'),
          actions: const [],
        ),
        body: Column(
          children: [const Text('This is Text'), innerWidget],
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(RumActionType.custom);
  });

  testWidgets('tap button reports tap to RUM', (tester) async {
    final mockRum = MockDdRum();

    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      ElevatedButton(
        onPressed: () {},
        child: const Text('This is a button'),
      ),
    ));

    final button = find.byType(ElevatedButton);
    await tester.tap(button);

    verify(() => mockRum.addAction(RumActionType.tap, any()));
  });

  testWidgets('tap elevated button reports button text to RUM', (tester) async {
    final mockRum = MockDdRum();

    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      ElevatedButton(
        onPressed: () {},
        child: Text(buttonText),
      ),
    ));

    final button = find.byType(ElevatedButton);
    await tester.tap(button);

    verify(() => mockRum.addAction(RumActionType.tap, 'Button($buttonText)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap text button reports button text to RUM', (tester) async {
    final mockRum = MockDdRum();

    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      TextButton(
        onPressed: () {},
        child: Text(buttonText),
      ),
    ));

    final button = find.byType(TextButton);
    await tester.tap(button);

    verify(() => mockRum.addAction(RumActionType.tap, 'Button($buttonText)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap outlined button reports button text to RUM', (tester) async {
    final mockRum = MockDdRum();

    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      OutlinedButton(
        onPressed: () {},
        child: Text(buttonText),
      ),
    ));

    final button = find.byType(OutlinedButton);
    await tester.tap(button);

    verify(() => mockRum.addAction(RumActionType.tap, 'Button($buttonText)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap text does not report tap to RUM', (tester) async {
    final mockRum = MockDdRum();

    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      ElevatedButton(
        onPressed: () {},
        child: Text(buttonText),
      ),
    ));

    final text = find.byType(Text).first;
    await tester.tap(text);

    verifyNever(() => mockRum.addAction(any(), any()));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap gesture detector with text reports unknown description',
      (tester) async {
    final mockRum = MockDdRum();

    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      GestureDetector(
        onTap: () {},
        child: Text(buttonText),
      ),
    ));

    final text = find.byType(GestureDetector);
    await tester.tap(text);

    verify(
        () => mockRum.addAction(RumActionType.tap, 'GestureDetector(unknown)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap gesture detector with annotation reports description',
      (tester) async {
    final mockRum = MockDdRum();

    final annotation = randomString();
    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      RumUserActionAnnotation(
        description: annotation,
        child: GestureDetector(
          onTap: () {},
          child: Text(buttonText),
        ),
      ),
    ));

    final text = find.byType(GestureDetector);
    await tester.tap(text);

    verify(() =>
        mockRum.addAction(RumActionType.tap, 'GestureDetector($annotation)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap button with annotation reports annotation over text',
      (tester) async {
    final mockRum = MockDdRum();

    final annotation = randomString();
    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      RumUserActionAnnotation(
        description: annotation,
        child: TextButton(
          onPressed: () {},
          child: Text(buttonText),
        ),
      ),
    ));

    final text = find.byType(TextButton);
    await tester.tap(text);

    verify(() => mockRum.addAction(RumActionType.tap, 'Button($annotation)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap disabled button does not report tap', (tester) async {
    final mockRum = MockDdRum();

    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      TextButton(
        onPressed: null,
        child: Text(buttonText),
      ),
    ));

    final text = find.byType(TextButton);
    await tester.tap(text);

    verifyNever(() => mockRum.addAction(any(), any()));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap non-tap gesture detector does not report tap',
      (tester) async {
    final mockRum = MockDdRum();

    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      GestureDetector(
        onLongPress: () {},
        child: Text(buttonText),
      ),
    ));

    final text = find.byType(GestureDetector);
    await tester.tap(text);

    verifyNever(() => mockRum.addAction(any(), any()));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap InkWell reports tap without inner text', (tester) async {
    final mockRum = MockDdRum();

    final buttonText = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      InkWell(
        onTap: () {},
        child: Text(buttonText),
      ),
    ));

    final text = find.byType(GestureDetector);
    await tester.tap(text);

    verify(() => mockRum.addAction(RumActionType.tap, 'InkWell(unknown)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap IconButton reports tap', (tester) async {
    final mockRum = MockDdRum();

    const icon = Icons.ac_unit;
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      IconButton(
        onPressed: () {},
        icon: const Icon(icon),
      ),
    ));

    final text = find.byType(GestureDetector);
    await tester.tap(text);

    verify(() => mockRum.addAction(RumActionType.tap, 'IconButton(unknown)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap IconButton reports tap with semantic label if available',
      (tester) async {
    final mockRum = MockDdRum();

    const icon = Icons.ac_unit;
    final semanticLabel = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      IconButton(
        onPressed: () {},
        icon: Icon(
          icon,
          semanticLabel: semanticLabel,
        ),
      ),
    ));

    final text = find.byType(GestureDetector);
    await tester.tap(text);

    verify(() =>
        mockRum.addAction(RumActionType.tap, 'IconButton($semanticLabel)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap Radio reports tap with value', (tester) async {
    final mockRum = MockDdRum();

    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      Radio(
        value: 1,
        groupValue: 0,
        onChanged: (value) {},
      ),
    ));

    final text = find.byType(Radio<int>);
    await tester.tap(text);

    verify(() => mockRum.addAction(RumActionType.tap, 'Radio(1)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap Radio reports tap with Tree annotation', (tester) async {
    final mockRum = MockDdRum();

    final annotation = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      RumUserActionAnnotation(
        description: annotation,
        child: Radio(
          value: 1,
          groupValue: 0,
          onChanged: (value) {},
        ),
      ),
    ));

    final text = find.byType(Radio<int>);
    await tester.tap(text);

    verify(() => mockRum.addAction(RumActionType.tap, 'Radio($annotation)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap Switch reports tap with Tree annotation', (tester) async {
    final mockRum = MockDdRum();

    final annotation = randomString();
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      RumUserActionAnnotation(
        description: annotation,
        child: Switch(
          value: false,
          onChanged: (value) {},
        ),
      ),
    ));

    final text = find.byType(Switch);
    await tester.tap(text);

    verify(() => mockRum.addAction(RumActionType.tap, 'Switch($annotation)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap BottomNavigationBar reports tap', (tester) async {
    final mockRum = MockDdRum();

    final app = RumUserActionDetector(
      rum: mockRum,
      child: MaterialApp(
        home: Scaffold(
          body: const Center(
            child: Text('Test'),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Business',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'School',
              ),
            ],
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);

    final navItem = find.byIcon(Icons.business).first;
    await tester.tap(navItem);

    verify(() => mockRum.addAction(
        RumActionType.tap, 'BottomNavigationBarItem(Business)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap BottomNavigationBar reports child annotation',
      (tester) async {
    final mockRum = MockDdRum();

    final app = RumUserActionDetector(
      rum: mockRum,
      child: MaterialApp(
        home: Scaffold(
          body: const Center(
            child: Text('Test'),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: RumUserActionAnnotation(
                  description: 'Custom Annotation',
                  attributes: {'custom_attribute': 12345},
                  child: Icon(Icons.business),
                ),
                label: 'Business',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'School',
              ),
            ],
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);

    final navItem = find.byIcon(Icons.business).first;
    await tester.tap(navItem);

    verify(() => mockRum.addAction(
          RumActionType.tap,
          'BottomNavigationBarItem(Custom Annotation)',
          {'custom_attribute': 12345},
        ));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap TabBar reports tap', (tester) async {
    final mockRum = MockDdRum();

    final app = RumUserActionDetector(
      rum: mockRum,
      child: DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test'),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.cloud_outlined,
                      semanticLabel: 'cloudy',
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.beach_access_sharp,
                      semanticLabel: 'rainy',
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.brightness_5_sharp,
                      semanticLabel: 'sunny',
                    ),
                  ),
                ],
              ),
            ),
            body: const TabBarView(children: [
              Center(child: Text('Test 1')),
              Center(child: Text('Test 2')),
              Center(child: Text('Test 3')),
            ]),
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);

    final navItem = find.byIcon(Icons.beach_access_sharp).first;
    await tester.tap(navItem);

    verify(() => mockRum.addAction(RumActionType.tap, 'Tab(rainy)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap TabBar reports tap with text over icon semantics',
      (tester) async {
    final mockRum = MockDdRum();

    final app = RumUserActionDetector(
      rum: mockRum,
      child: DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test'),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.cloud_outlined,
                      semanticLabel: 'cloudy',
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.beach_access_sharp,
                      semanticLabel: 'rainy',
                    ),
                    text: 'Rainy Days',
                  ),
                  Tab(
                    icon: Icon(
                      Icons.brightness_5_sharp,
                      semanticLabel: 'sunny',
                    ),
                  ),
                ],
              ),
            ),
            body: const TabBarView(children: [
              Center(child: Text('Test 1')),
              Center(child: Text('Test 2')),
              Center(child: Text('Test 3')),
            ]),
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);

    final navItem = find.byIcon(Icons.beach_access_sharp).first;
    await tester.tap(navItem);

    verify(() => mockRum.addAction(RumActionType.tap, 'Tab(Rainy Days)'));
    verifyNoMoreInteractions(mockRum);
  });

  testWidgets('tap gesture detector with annotation reports attributes',
      (tester) async {
    final mockRum = MockDdRum();

    final annotation = randomString();
    final buttonText = randomString();
    final attributes = {'test_key': randomString()};
    await tester.pumpWidget(_buildSimpleApp(
      mockRum,
      RumUserActionAnnotation(
        description: annotation,
        attributes: attributes,
        child: GestureDetector(
          onTap: () {},
          child: Text(buttonText),
        ),
      ),
    ));

    final text = find.byType(GestureDetector);
    await tester.tap(text);

    verify(() => mockRum.addAction(RumActionType.tap, any(), attributes));
    verifyNoMoreInteractions(mockRum);
  });

  group('tap custom widget', () {
    testWidgets('reports tap to RUM with unknown annotation by default',
        (tester) async {
      final mockRum = MockDdRum();

      await tester.pumpWidget(_buildSimpleApp(
        mockRum,
        _DescriptiveWidget(),
      ));

      final button = find.byType(_DescriptiveWidget);
      await tester.tap(button);

      verify(() =>
          mockRum.addAction(RumActionType.tap, 'DescriptiveWidget(unknown)'));
    });

    testWidgets('reports tap to RUM and search for better widget',
        (tester) async {
      final mockRum = MockDdRum();

      final annotation = randomString();
      await tester.pumpWidget(_buildSimpleApp(
        mockRum,
        _VagueWidget(
          child: ElevatedButton(
            onPressed: () {},
            child: Text(annotation),
          ),
        ),
      ));

      final button = find.byType(_VagueWidget);
      await tester.tap(button);

      verify(() => mockRum.addAction(RumActionType.tap, 'Button($annotation)'));
    });

    testWidgets('reports tap to RUM and search for text', (tester) async {
      final mockRum = MockDdRum();

      final annotation = randomString();
      await tester.pumpWidget(_buildSimpleApp(
        mockRum,
        _VagueWidget(
          child: Text(annotation),
        ),
      ));

      final button = find.byType(_VagueWidget);
      await tester.tap(button);

      verify(() =>
          mockRum.addAction(RumActionType.tap, 'VagueWidget($annotation)'));
    });

    testWidgets(
        'reports tap to RUM '
        'and do not search for text '
        'and do not search for better widget', (tester) async {
      final mockRum = MockDdRum();

      final annotation = randomString();
      await tester.pumpWidget(_buildSimpleApp(
        mockRum,
        _DescriptiveWidget(
          child: ElevatedButton(
            onPressed: () {},
            child: Text(annotation),
          ),
        ),
      ));

      final button = find.byType(_DescriptiveWidget);
      await tester.tap(button);

      verify(() =>
          mockRum.addAction(RumActionType.tap, 'DescriptiveWidget(unknown)'));
    });

    testWidgets('with annotation reports description', (tester) async {
      final mockRum = MockDdRum();

      final annotation = randomString();
      await tester.pumpWidget(_buildSimpleApp(
        mockRum,
        RumUserActionAnnotation(
          description: annotation,
          child: _DescriptiveWidget(),
        ),
      ));

      final text = find.byType(_DescriptiveWidget);
      await tester.tap(text);

      verify(() => mockRum.addAction(
          RumActionType.tap, 'DescriptiveWidget($annotation)'));
      verifyNoMoreInteractions(mockRum);
    });

    testWidgets('with annotation in subtree reports description',
        (tester) async {
      final mockRum = MockDdRum();

      final annotation = randomString();
      final attributes = {'test_key': randomString()};
      await tester.pumpWidget(
        _buildSimpleApp(
          mockRum,
          _VagueWidget(
            child: RumUserActionAnnotation(
              description: annotation,
              attributes: attributes,
              child: Semantics(
                child: SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      final text = find.byType(_VagueWidget);
      await tester.tap(text);

      verify(
        () => mockRum.addAction(
            RumActionType.tap, 'VagueWidget($annotation)', attributes),
      );
      verifyNoMoreInteractions(mockRum);
    });
  });
}
