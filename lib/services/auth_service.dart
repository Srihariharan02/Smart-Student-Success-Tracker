import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<({String token, UserModel user})> login(String identifier, String password, {bool rememberMe = true}) async {
    final response = await _client.post(
      ApiConstants.login,
      body: {
        'identifier': identifier.trim(),
        'email': identifier.trim(),
        'password': password,
      },
    );

    final data = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final token = data['access_token'] ?? data['token'] ?? '';
    final userJson = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : <String, dynamic>{};

    final user = UserModel.fromJson(userJson);

    await LocalStorage.saveRememberMe(rememberMe);
    if (token.isNotEmpty && rememberMe) {
      await LocalStorage.saveToken(token);
      await LocalStorage.saveUser(user.toJson());
    } else if (token.isNotEmpty) {
      await LocalStorage.saveToken(token);
      await LocalStorage.saveUser(user.toJson());
    }

    return (token: token.toString(), user: user);
  }

  Future<Map<String, dynamic>> requestPasswordOtp(String identifier) async {
    final response = await _client.post(
      ApiConstants.forgotPassword,
      body: {'identifier': identifier.trim(), 'email': identifier.trim()},
    );
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  Future<void> verifyPasswordOtp(String identifier, String otp) async {
    await _client.post(
      ApiConstants.verifyOtp,
      body: {'identifier': identifier.trim(), 'otp': otp.trim()},
    );
  }

  Future<void> resetPasswordWithOtp({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    await _client.post(
      ApiConstants.resetPassword,
      body: {
        'identifier': identifier.trim(),
        'otp': otp.trim(),
        'new_password': newPassword,
      },
    );
  }

  Future<UserModel> getProfile() async {
    final response = await _client.get(ApiConstants.me);
    final data = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final userJson = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    final user = UserModel.fromJson(userJson);
    await LocalStorage.saveUser(user.toJson());
    return user;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _client.put(
      ApiConstants.changePassword,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {}
    await LocalStorage.clearToken();
    await LocalStorage.clearUser();
  }
}
