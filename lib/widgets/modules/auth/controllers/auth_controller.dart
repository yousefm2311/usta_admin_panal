import 'package:get/get.dart';
import 'package:usta_admin_panal/core/services/api_client.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/services/token_storage.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthController({AuthService? authService, TokenStorage? tokenStorage})
      : _authService = authService ?? AuthService(),
        _tokenStorage = tokenStorage ?? Get.find<TokenStorage>();

  final loading = false.obs;
  final error = RxnString();

  Future<bool> login(String email, String password) async {
    loading.value = true;
    error.value = null;
    try {
      final tokens = await _authService.login(email: email, password: password);
      await _tokenStorage.saveTokens(tokens.token, refreshToken: tokens.refreshToken);
      ApiClient().dio.options.headers['Authorization'] =
          "Bearer ${tokens.token}";
      await _authService.verifyRole();
      return true;
    } catch (e) {
      if (e is ApiException) {
        error.value = e.message;
      } else {
        error.value = e.toString();
      }
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout({bool callApi = true}) async {
    if (callApi && isLoggedIn) {
      try {
        await _authService.logout();
      } catch (_) {}
    }

    await _tokenStorage.markLoggedOut();
    await _tokenStorage.clear();
    ApiClient().dio.options.headers.remove('Authorization');
    Get.offAllNamed('/login');
  }


  bool get isLoggedIn => (_tokenStorage.token ?? '').isNotEmpty;
}
