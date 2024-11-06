import 'dart:async';
import 'dart:convert';

import 'package:firebase_dart_admin_auth_sdk/src/firebase_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/firebase_storage.dart';
import 'package:firebase_dart_admin_auth_sdk/src/service_account.dart';
import 'package:firebase_dart_admin_auth_sdk/src/user.dart';
import 'auth/generate_custom_token.dart';
import 'auth/get_access_token_with_generated_token.dart';

class FirebaseApp {
  ///Instance of the Firebase App
  static FirebaseApp? _instance;
  //API key associated with the project
  final String? _apiKey;
  //The ID of the project
  final String? _projectId;
  //The authDomain of the project
  final String _authdomain;
  //The messagingSenderId of the project
  final String _messagingSenderId;
  final String? _bucketName;
  final String? _appId;
  final ServiceAccount? _serviceAccount;
  final String? _accessToken;
  static FirebaseAuth? firebaseAuth;
  static GetAccessTokenWithGeneratedToken? _accesstokenGen;
  static GenerateCustomToken? _tokenGen;
  static FirebaseStorage? firebaseStorage;

  FirebaseApp._(
      this._apiKey,
      this._projectId,
      this._authdomain,
      this._messagingSenderId,
      this._bucketName,
      this._appId,
      this._serviceAccount,
      this._accessToken);

  User? _currentUser;

  // method to set the current user
  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  User? getCurrentUser() {
    return _currentUser;
  }

  //Exposes the singleton
  static FirebaseApp get instance {
    if (_instance == null) {
      throw ("FirebaseApp is not initialized. Please call initializeApp() first.");
    }
    return _instance!;
  }

  ///Used to initialize the project
  ///[apiKey] is the API Key associated with the project
  ///[projectId] is the ID of the project
  static Future<FirebaseApp> initializeAppWithEnvironmentVariables({
    required String apiKey,
    required String authdomain,
    required String projectId,
    required String messagingSenderId,
    required String bucketName,
    required String appId,
  }) async {
    // Asserts that the API key, Project ID, and Bucket Name are not empty
    assert(apiKey.isNotEmpty, "API Key cannot be empty");
    assert(projectId.isNotEmpty, "Project ID cannot be empty");
    assert(bucketName.isNotEmpty, "Bucket Name cannot be empty");
    assert(authdomain.isNotEmpty, "Auth Domain cannot be empty");
    assert(messagingSenderId.isNotEmpty, "Messaging Sender ID cannot be empty");
    assert(appId.isNotEmpty, "App ID cannot be empty");

    // Returns an instance of FirebaseApp if it exists or create a new instance based on the parameters passed
    return _instance ??= FirebaseApp._(
      apiKey,
      projectId,
      authdomain,
      messagingSenderId,
      bucketName,
      appId,
      null,
      null,
    );
  }

  static Future<FirebaseApp> initializeAppWithServiceAccount({
    required String serviceAccountContent,
    required String serviceAccountKeyFilePath,
  }) async {
    // Initialize token generators
    final tokenGen = _tokenGen ??= GenerateCustomTokenImplementation();
    final accesTokenGen =
        _accesstokenGen ??= GetAccessTokenWithGeneratedTokenImplementation();

    try {
      // Parse the JSON content
      final Map<String, dynamic> serviceAccount =
          json.decode(serviceAccountContent);

      // Create ServiceAccount model from JSON
      final ServiceAccount serviceAccountModel =
          ServiceAccount.fromJson(serviceAccount);

      // Generate JWT and access token
      final jwt = await tokenGen.generateServiceAccountJwt(serviceAccountModel);
      final accessToken =
          await accesTokenGen.getAccessTokenWithGeneratedToken(jwt);

      // Extract values with defaults for optional fields
      final projectId = serviceAccount['project_id'];
      final authDomain = serviceAccount['auth_domain'] ?? '';
      final messagingSenderId = serviceAccount['messaging_sender_id'] ?? '';
      final bucketName = serviceAccount['bucket_name'];
      final appId = serviceAccount['app_id'];

      // Validate required fields
      if (projectId == null) {
        throw FormatException('Missing project_id in service account JSON');
      }

      // Create and return Firebase instance
      return _instance ??= FirebaseApp._(
        null,
        projectId,
        authDomain,
        messagingSenderId,
        bucketName,
        appId,
        serviceAccountModel,
        accessToken,
      );
    } catch (e) {
      throw Exception('Failed to initialize Firebase with service account: $e');
    }
  }

  static Future<FirebaseApp> initializeAppWithServiceAccountImpersonation({
    required String serviceAccountEmail,
    required String userEmail,
  }) async {
    // Assert the values passed are not empty
    assert(serviceAccountEmail.isNotEmpty,
        "Service Account Email cannot be empty");
    assert(userEmail.isNotEmpty, "User email cannot be empty");

    // TODO: Implement API to get access token

    return _instance ??= FirebaseApp._(
      'your_api_key',
      'your_project_id',
      'your_auth_domain',
      'your_messaging_sender_id',
      'your_bucket_name',
      'your_app_id',
      null,
      null,
    );
  }

  ///Returns a Firebase Auth instance associated with the Project
  ///Throws not initialized if Firebase app is not intialized
  FirebaseAuth getAuth() {
    if (_accessToken == null) assert(_apiKey != null, 'API Key is null');
    assert(_projectId != null, 'Project ID is null');
    if (_instance == null) {
      throw ("FirebaseApp is not initialized. Please call initializeApp() first.");
    }
    return firebaseAuth ??= FirebaseAuth(
      apiKey: _apiKey,
      projectId: _projectId,
      authDomain: _authdomain,
      messagingSenderId: _messagingSenderId,
      bucketName: _bucketName,
      accessToken: _accessToken,
      serviceAccount: _serviceAccount,
      generateCustomToken: _tokenGen,
      appId: _appId,
    );
  }

  FirebaseStorage getStorage() {
    assert(_apiKey != null, 'API Key is null');
    assert(_projectId != null, 'Project ID is null');
    if (_instance == null) {
      throw ("FirebaseApp is not initialized. Please call initializeApp() first.");
    }
    // Use the getStorage method to obtain a FirebaseStorage instance
    return firebaseStorage ??= FirebaseStorage.getStorage(
      apiKey: _apiKey!,
      projectId: _projectId!,
      bucketName: _bucketName!,
    );
  }
}
