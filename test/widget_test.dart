import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frip_cash/main.dart';
import 'package:frip_cash/screens/forgot_password_screen.dart';
import 'package:frip_cash/screens/help_screen.dart';
import 'package:frip_cash/screens/login_screen.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/screens/otp_verification_screen.dart';
import 'package:frip_cash/screens/signup_screen.dart';
import 'package:frip_cash/screens/verification_loader_screen.dart';
import 'package:frip_cash/screens/welcome_screen.dart';

void main() {
  testWidgets('Splash screen shows FripCash logo', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(Image), findsOneWidget);
    expect(
      (tester.widget<Image>(find.byType(Image)).image as AssetImage).assetName,
      'assets/images/logo.png',
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Sign up for FripCash'), findsOneWidget);
  });

  testWidgets('Welcome screen shows masonry grid and CTAs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WelcomeScreen()),
    );

    expect(find.text('Join and sell pre-loved clothes with no fees'),
        findsOneWidget);
    expect(find.text('Sign up for FripCash'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('Login screen shows form and consent checkboxes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    expect(find.text('Bon retour !'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(Checkbox), findsNWidgets(2));
  });

  testWidgets('Sign up screen shows form and submit button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: SignUpScreen()),
    );

    expect(find.text('Rejoins FripCash'), findsOneWidget);
    expect(find.text('S\'inscrire'), findsOneWidget);
    expect(find.text('Confirmer le mot de passe'), findsOneWidget);
    expect(find.byType(Checkbox), findsNWidgets(2));
  });

  testWidgets('Forgot password screen shows phone field',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ForgotPasswordScreen()),
    );

    expect(find.text('Mot de passe oublié'), findsOneWidget);
    expect(find.text('Envoyer le code'), findsOneWidget);
  });

  testWidgets('OTP screen shows verification UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpVerificationScreen(phoneNumber: '612345678'),
      ),
    );

    expect(find.text('Vérification'), findsOneWidget);
    expect(find.text('Vérifier'), findsOneWidget);
  });

  testWidgets('Verification loader shows logo and status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VerificationLoaderScreen(
          nextScreen: const LoginScreen(),
          duration: const Duration(seconds: 30),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(
      find.textContaining('Vérification de l\'appareil'),
      findsOneWidget,
    );
  });

  testWidgets('Help screen shows FAQ and contact options',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HelpScreen()),
    );

    expect(find.text('Besoin d\'aide ?'), findsOneWidget);
    expect(find.text('Contacter le support'), findsOneWidget);
    expect(find.text('Comment créer un compte ?'), findsOneWidget);
  });

  testWidgets('Home tab shows product grid', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainShell()),
    );

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Explorer les catégories'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Articles populaires'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Articles populaires'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Nouveautés'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Nouveautés'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Recommandé pour toi'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recommandé pour toi'), findsOneWidget);
  });

  testWidgets('Favorites tab shows saved items', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainShell()),
    );

    await tester.tap(find.text('Favoris'));
    await tester.pumpAndSettle();

    expect(find.text('Favoris'), findsWidgets);
    expect(find.text('Robe fleurie vintage'), findsNothing);
    expect(find.text('Zara'), findsOneWidget);
  });

  testWidgets('Product detail opens from home grid', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainShell()),
    );

    await tester.scrollUntilVisible(
      find.text('Recommandé pour toi'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zara').first);
    await tester.pumpAndSettle();

    expect(find.text('Faire une offre'), findsOneWidget);
    expect(find.text('Acheter'), findsOneWidget);
    expect(find.text('Message'), findsNothing);
    expect(find.text('Demander'), findsOneWidget);
  });

  testWidgets('Profile tab shows menu items', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainShell()),
    );

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Vends tes articles'), findsOneWidget);
    expect(find.text('Mon porte-monnaie'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Se déconnecter'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Se déconnecter'), findsOneWidget);
  });

  testWidgets('Inbox tab shows empty illustration', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainShell()),
    );

    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();

    expect(find.text('Aucun message'), findsOneWidget);
  });

  testWidgets('Cart sheet opens from home header', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainShell()),
    );

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Ton panier est vide'), findsOneWidget);
    expect(find.text('Mon panier (0)'), findsOneWidget);
  });
}
