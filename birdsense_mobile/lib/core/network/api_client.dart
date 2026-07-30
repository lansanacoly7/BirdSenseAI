import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Client HTTP centralisé pour les appels au backend BirdSense AI.
///
/// Encapsule une instance [Dio] pré-configurée avec :
/// - Un timeout de connexion de 5 secondes.
/// - Un timeout de réception de 10 secondes.
/// - Un intercepteur d'authentification JWT automatique.
///
/// Le token JWT est lu depuis [FlutterSecureStorage] à chaque requête.
/// Si aucun token n'est disponible, la requête part sans header
/// `Authorization` (utile pour les endpoints publics).
class ApiClient {
  /// Instance Dio exposée pour les appels réseau.
  final Dio dio;

  final FlutterSecureStorage _secureStorage;

  /// Crée un [ApiClient] pointant vers [baseUrl].
  ///
  /// [secureStorage] est injectable pour faciliter les tests.
  ApiClient({required String baseUrl, FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(_authInterceptor());
  }

  /// Intercepteur qui injecte le JWT dans le header Authorization.
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    );
  }
}
