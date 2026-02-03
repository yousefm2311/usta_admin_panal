import 'package:get/get.dart';

import '../services/token_storage.dart';
import '../services/http_client.dart';
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TokenStorage>(TokenStorage(), permanent: true);
    Get.put<HttpClient>(HttpClient(tokenStorage: Get.find<TokenStorage>()), permanent: true);
  }
}
