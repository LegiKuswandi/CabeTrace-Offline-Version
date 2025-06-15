import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Import halaman login dan home
// import 'loginPage.dart';
import 'homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   checkLoginStatus();
  // }

  Future<void> checkLoginStatus() async {
    // final prefs = await SharedPreferences.getInstance();
    // final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    // final username = prefs.getString('username') ?? '';

    await Future.delayed(const Duration(seconds: 2));


    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(username: "legi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF008000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image(
              image: AssetImage('asset/images/logowo.png'),
              width: 180,
              height: 180,
            ),
            SizedBox(height: 20),
            Text(
              'CabeTrace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Text(
                'Dari Daun ke Data, Semua dalam Genggaman!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
