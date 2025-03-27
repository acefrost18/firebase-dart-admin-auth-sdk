import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:firebase_dart_admin_auth_sdk/src/http_response.dart';
import 'package:mockito/mockito.dart' as mockito;
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
void main() {
  group('FirebaseAuth Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
    });

    test('performRequest handles typed arguments correctly', () async {
      // Arrange
      const endpoint = 'update';
      const body = {'key': 'value'};
      final expectedResponse = HttpResponse(
        statusCode: 200,
        body: {'message': 'Success'},
      );

      mockito.when(mockFirebaseAuth.performRequest(endpoint, body))
        .thenAnswer((_) async => expectedResponse);
     
      final result = await mockFirebaseAuth.performRequest(endpoint, body);

      // Assert
      expect(result.statusCode, equals(200));
      expect(result.body, containsPair('message', 'Success'));

      mockito.verify(mockFirebaseAuth.performRequest(endpoint, body)).called(1);
    });
  });
}
