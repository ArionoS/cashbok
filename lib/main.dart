import 'package:flutter/material.dart';
import 'package:cashbook/screens/history.dart';
import 'package:cashbook/screens/home_screen.dart';
import 'package:cashbook/screens/login_screen.dart';
import 'package:cashbook/screens/add_transaction_screen.dart';
import 'package:cashbook/screens/setting_screen.dart';
import 'package:cashbook/services/authentication_service.dart';
import 'package:cashbook/db/database.dart';
import 'package:cashbook/services/data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseHelper = HiveDatabaseHelper();
  await databaseHelper.initDatabase();

  final authService = AuthenticationService(databaseHelper);
  final dataService = DataService(databaseHelper);
  final isLoggedIn = await authService.isUserLoggedIn();
  runApp(
    MainApp(
        authService: authService,
        dataService: dataService,
        isLoggedIn: isLoggedIn),
  );
}

class MainApp extends StatelessWidget {
  const MainApp(
      {Key? key,
      required this.authService,
      required this.dataService,
      required this.isLoggedIn})
      : super(key: key);
  final AuthenticationService authService;
  final DataService dataService;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Cash Book',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(isLoggedIn: isLoggedIn),
        '/login': (context) => LoginScreen(authService: authService),
        '/home': (context) =>
            HomeScreen(authService: authService, dataService: dataService),
        '/add_transaction': (context) => AddTransactionScreen(
              transactionType: ModalRoute.of(context)!.settings.arguments,
              dataService: dataService,
            ),
        '/history': (context) => HistoryScreen(dataService: dataService),
        '/settings': (context) => SettingScreen(authService: authService),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key, required this.isLoggedIn}) : super(key: key);
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'My Cash Book',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (isLoggedIn) {
                  Navigator.of(context).pushNamed('/home');
                } else {
                  Navigator.of(context).pushNamed('/login');
                }
              },
              child: Text(isLoggedIn ? 'Continue' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}
