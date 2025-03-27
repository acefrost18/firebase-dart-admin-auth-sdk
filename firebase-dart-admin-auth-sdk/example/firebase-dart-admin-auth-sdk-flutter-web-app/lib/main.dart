import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase/screens/splash_screen/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'https://www.googleapis.com/auth/cloud-platform'],
);
Future<String> getAuthTokenFromGoogleSignIn() async {
  try {
    // Sign in the user
    GoogleSignInAccount? user = await _googleSignIn.signIn();

    if (user == null) {
      throw Exception("User canceled the sign-in process.");
    }

    // Retrieve authentication credentials
    GoogleSignInAuthentication auth = await user.authentication;

    // Get the access token
    String accessToken = auth.accessToken!;
    print('Access Token: $accessToken');

    return accessToken;
  } catch (e) {
    print("Error during Google sign-in: $e");
    throw Exception('Failed to get access token: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    late FirebaseAuth auth; 

    if (kIsWeb) {
      debugPrint('Initializing Firebase for Web...');
      await FirebaseApp.initializeAppWithEnvironmentVariables(
        apiKey: 'AIzaSyDbmws6yjN0B8zjz4Y005yoYQaGAhAQpQo',           
        authdomain: 'sph-2025-mt-l-smith.firebaseapp.com',     
        projectId: 'sph-2025-mt-l-smith',       
        messagingSenderId: '215633423958', 
        bucketName: 'sph-2025-mt-l-smith.firebasestorage.com',  
        appId: '1:215633423958:web:81089f6a361086a5de95f7',               
      );
      auth = FirebaseApp.instance.getAuth();
      debugPrint('Firebase initialized for Web.');
    } else {
      
      await FirebaseApp.initializeWithServiceAccountImpersonation(
        serviceAccountEmail: "'your-target-service-account@your-project.iam.gserviceaccount.com",
      );
      auth = FirebaseApp.instance.getAuth();
    }

    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "893849532657430",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );

    //   // Initialize for web
    //   debugPrint('Initializing Firebase for Web...');
    //   await FirebaseApp.initializeAppWithEnvironmentVariables(
    //     apiKey: 'YOUR_API_KEY', // 'YOUR_API_KEY'
    //     authdomain: 'YOUR_AUTH_DOMAIN', // 'YOUR_AUTH_DOMAIN'
    //     projectId: 'YOUR_PROJECT_ID', // 'YOUR_PROJECT_ID'
    //     messagingSenderId: 'YOUR_SENDER_ID', // 'YOUR_SENDER_ID'
    //     bucketName: 'YOUR_BUCKET_NAME', // 'YOUR_BUCKET_NAME'
    //     appId: 'YOUR_APP_ID', // 'YOUR_APP_ID'
    //   );
    //   auth = FirebaseApp.instance.getAuth(); // Initialize auth for web
    //   debugPrint('Firebase initialized for Web.');
    // } else {
    //   if (Platform.isAndroid || Platform.isIOS) {
    //     debugPrint('Initializing Firebase for Mobile...');

    //     // Load the service account JSON
    //     // String serviceAccountContent = await rootBundle.loadString(
    //     //   'assets/service_account.json',
    //     // );

    //     debugPrint('Service account loaded.');

    //     // Initialize Firebase with the service account content
    //     // await FirebaseApp.initializeAppWithServiceAccount(
    //     //   serviceAccountContent: serviceAccountContent,
    //     // );

    //     await FirebaseApp.initializeAppWithServiceAccountImpersonationGCP(
    //       gcpAccessToken: 'gcp-access-token',
    //       impersonatedEmail: 'account-to-be-impersonated',
    //     );
    //     auth = FirebaseApp.instance.getAuth(); // Initialize auth for mobile
    //     debugPrint('Firebase initialized for Mobile.');

    //     // Uncomment to use service account impersonation if needed
    //     /*
    //     await FirebaseApp.initializeAppWithServiceAccountImpersonation(
    //       impersonatedEmail: 'impersonatedEmail',
    //       serviceAccountContent: serviceAccountContent,
    //     );
    //     debugPrint('Firebase initialized with service account impersonation.');
    //     */
    //   }
    // }

    debugPrint('Firebase Auth instance obtained.');

    runApp(
      Provider<FirebaseAuth>.value(
        value: auth,
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Error initializing Firebase: $e');
    debugPrint('StackTrace: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Admin Demo',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Wrap SplashScreen with Builder to ensure proper context
      home: Builder(
        builder: (context) => const SplashScreen(),
      ),
    );
  }
}

