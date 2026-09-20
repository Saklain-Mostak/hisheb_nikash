import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisab_nikash/core/widgets/app_card.dart';
import 'package:hisab_nikash/core/widgets/empty_state_view.dart';

void main() {
  testWidgets('EmptyStateView renders title and message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateView(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            message: 'Quickly record an expense or income.',
          ),
        ),
      ),
    );

    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.text('Quickly record an expense or income.'), findsOneWidget);
  });

  testWidgets('AppCard renders child content', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            child: Text('Card Content Test'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content Test'), findsOneWidget);
  });
}
