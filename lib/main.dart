import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/prompt/providers/prompt_provider.dart';
import 'features/prompt/providers/theme_provider.dart';
import 'onboarding/screens/onboarding_screen.dart';
import 'splash/screens/splash_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;
  // await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PromptProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: AiImageGenerator(showOnboarding: showOnboarding),
    ),
  );
}

class AiImageGenerator extends StatelessWidget {
  final bool showOnboarding;

  const AiImageGenerator({Key? key, required this.showOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          title: 'AI Image Generator',
          theme: CupertinoThemeData(
            brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            primaryColor: CupertinoColors.systemIndigo,
            scaffoldBackgroundColor: themeProvider.isDarkMode
                ? CupertinoColors.black
                : CupertinoColors.extraLightBackgroundGray,
            barBackgroundColor: themeProvider.isDarkMode
                ? CupertinoColors.black
                : CupertinoColors.white,
            textTheme: CupertinoTextThemeData(
              primaryColor: themeProvider.isDarkMode
                  ? CupertinoColors.white
                  : CupertinoColors.black,
            ),
          ),
          home: showOnboarding
              ? const SplashScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
