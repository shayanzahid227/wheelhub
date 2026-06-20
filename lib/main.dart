import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/auth/screens/splash/splash_screen.dart';
import 'package:wheelhub/auth/viewmodels/auth_viewmodel.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WheelHubApp());
}

class WheelHubApp extends StatelessWidget {
  const WheelHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
      ],
      child: MaterialApp(
        title: 'wheelHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
