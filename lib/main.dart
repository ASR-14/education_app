import 'package:education_app/core/common/app/providers/course_of_the_day_notifier.dart';
import 'package:education_app/core/common/app/providers/notifications_notifier.dart';
import 'package:education_app/core/common/app/providers/user_provider.dart';
import 'package:education_app/core/res/colours.dart';
import 'package:education_app/core/res/fonts.dart';
import 'package:education_app/core/secrets/secrets.dart';
import 'package:education_app/core/services/injection_container.dart';
import 'package:education_app/core/services/router.dart';
import 'package:education_app/firebase_options.dart';
import 'package:education_app/src/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:education_app/src/search/presentation/providers/search_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseKey,
  );
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => CourseOfTheDayNotifier()),
        ChangeNotifierProvider(
          create: (_) => NotificationsNotifier(sl<SharedPreferences>()),
        ),
        ChangeNotifierProvider(create: (_) => sl<SearchProvider>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Education App',
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: Fonts.poppins,
          appBarTheme: const AppBarTheme(
            color: Colors.transparent,
          ),
          colorScheme:
              ColorScheme.fromSwatch(accentColor: Colours.primaryColour),
        ),
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
