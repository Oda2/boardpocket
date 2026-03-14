import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/settings/settings_components.dart';

void main() {
  group('SettingsSection', () {
    testWidgets('renders title in uppercase', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSection(
              title: 'Appearance',
              children: [Text('Content')],
            ),
          ),
        ),
      );

      expect(find.text('APPEARANCE'), findsOneWidget);
    });

    testWidgets('renders children', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSection(
              title: 'Test',
              children: [Text('Child Widget')],
            ),
          ),
        ),
      );

      expect(find.text('Child Widget'), findsOneWidget);
    });
  });

  group('SettingsListTile', () {
    testWidgets('renders icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListTile(
              icon: Icons.settings,
              iconColor: Colors.blue,
              title: 'Settings',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListTile(
              icon: Icons.settings,
              iconColor: Colors.blue,
              title: 'Settings Title',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Settings Title'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListTile(
              icon: Icons.settings,
              iconColor: Colors.blue,
              title: 'Title',
              subtitle: 'Subtitle here',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Subtitle here'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListTile(
              icon: Icons.settings,
              iconColor: Colors.blue,
              title: 'Title',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Title'));
      expect(tapped, isTrue);
    });

    testWidgets('renders trailing widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListTile(
              icon: Icons.settings,
              iconColor: Colors.blue,
              title: 'Title',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });

  group('SettingsToggle', () {
    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggle(
              icon: Icons.dark_mode,
              iconColor: Colors.indigo,
              title: 'Dark Mode',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('renders icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggle(
              icon: Icons.dark_mode,
              iconColor: Colors.indigo,
              title: 'Dark Mode',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('shows correct switch value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggle(
              icon: Icons.dark_mode,
              iconColor: Colors.indigo,
              title: 'Dark Mode',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('calls onChanged when toggled', (WidgetTester tester) async {
      bool? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggle(
              icon: Icons.dark_mode,
              iconColor: Colors.indigo,
              title: 'Dark Mode',
              value: false,
              onChanged: (value) => newValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      expect(newValue, isTrue);
    });
  });

  group('SettingsActionButtons', () {
    testWidgets('renders all buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsActionButtons(
              buttons: const [
                SettingsActionButton(label: 'Export'),
                SettingsActionButton(label: 'Import'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Export'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);
    });

    testWidgets('calls onPressed when button is tapped', (
      WidgetTester tester,
    ) async {
      bool exportPressed = false;
      bool importPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsActionButtons(
              buttons: [
                SettingsActionButton(
                  label: 'Export',
                  onPressed: () => exportPressed = true,
                ),
                SettingsActionButton(
                  label: 'Import',
                  onPressed: () => importPressed = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Export'));
      expect(exportPressed, isTrue);

      await tester.tap(find.text('Import'));
      expect(importPressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsActionButtons(
              buttons: const [
                SettingsActionButton(label: 'Export', isLoading: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('UserCard', () {
    testWidgets('renders name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserCard(name: 'John Doe', subtitle: 'Board Game Collector'),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('renders subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserCard(name: 'John Doe', subtitle: 'Board Game Collector'),
          ),
        ),
      );

      expect(find.text('Board Game Collector'), findsOneWidget);
    });

    testWidgets('renders avatar when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              name: 'John Doe',
              subtitle: 'Collector',
              avatar: Container(key: const Key('custom-avatar')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom-avatar')), findsOneWidget);
    });

    testWidgets(
      'shows default avatar with first letter when no avatar provided',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UserCard(name: 'John', subtitle: 'Collector'),
            ),
          ),
        );

        expect(find.text('J'), findsOneWidget);
      },
    );
  });

  group('SettingsDivider', () {
    testWidgets('renders Divider widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDivider())),
      );

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
