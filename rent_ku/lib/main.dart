import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/barang_provider.dart';
import 'providers/transaksi_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLogin()),
        ChangeNotifierProvider(create: (_) => BarangProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'RentKU',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blueAccent,
              textTheme: GoogleFonts.poppinsTextTheme(),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blueAccent,
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
              brightness: Brightness.dark,
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan baris ini untuk testing biar onboarding muncul terus
    // await prefs.setBool('showOnboarding', true); 
    setState(() {
      _showOnboarding = prefs.getBool('showOnboarding') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showOnboarding!) {
      return OnboardingScreen(onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showOnboarding', false);
        setState(() => _showOnboarding = false);
      });
    }

    final auth = context.watch<AuthProvider>();

    if (auth.isAuthenticated) {
      if (auth.user?.role == 'admin') {
        return const AdminDashboard();
      }
      return const MainNavigationScreen();
    }
    return const LoginScreen();
  }
}
