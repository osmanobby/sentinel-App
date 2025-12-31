import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/auth_wrapper.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/main_screen.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';

void main() {
  group('Digital Wellbeing App', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('Renders login screen when not authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: AuthWrapper(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Renders main screen when authenticated', (WidgetTester tester) async {
      // Sign in the user
      await mockAuth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password');

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: AuthWrapper(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        ),
      );

      // The AuthWrapper should now build the MainScreen
      expect(find.byType(MainScreen), findsOneWidget);
    });
  });
}
