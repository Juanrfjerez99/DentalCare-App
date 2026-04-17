import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'ui/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://shfppaqdbezxtwujkvfu.supabase.co',
    anonKey: 'sb_publishable_cnY4wyNT7pr-gZa-hq9fWw_Tn23Uaex',
  );

  runApp(const DentalCareApp());
}

class DentalCareApp extends StatelessWidget {
  const DentalCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DentalCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LoginScreen(),
    );
  }
}
