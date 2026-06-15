import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/fare_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/passenger_screen.dart';
import 'screens/driver_screen.dart';
import 'screens/regulator_screen.dart';
import 'screens/live_demo_screen.dart';
import 'screens/audit_ledger_screen.dart';
import 'screens/rate_card_screen.dart';
import 'screens/disputes_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/how_it_works_screen.dart';
import 'screens/api_access_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FareIQApp());
}

class FareIQApp extends StatelessWidget {
  const FareIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FareProvider()),
        ChangeNotifierProvider(create: (_) => RegulatorProvider()),
      ],
      child: MaterialApp(
        title: 'FareIQ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A237E),
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF0F2F8),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/': (_) => const DashboardScreen(),
          '/passenger': (_) => const PassengerScreen(),
          '/driver': (_) => const DriverScreen(),
          '/regulator': (_) => const RegulatorScreen(),
          '/live-demo': (_) => const LiveDemoScreen(),
          '/audit': (_) => const AuditLedgerScreen(),
          '/rate-card': (_) => const RateCardScreen(),
          '/disputes': (_) => const DisputesScreen(),
          '/reports': (_) => const ReportsScreen(),
          '/how-it-works': (_) => const HowItWorksScreen(),
          '/api-access': (_) => const ApiAccessScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}