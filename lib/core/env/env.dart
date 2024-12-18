import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_KEY_GOOGLE_PLAY', obfuscate: true)
  static final String apiKeyGoogle = _Env.apiKeyGoogle;

  @EnviedField(varName: 'API_KEY_APPLE', obfuscate: true)
  static final String apiKeyApple = _Env.apiKeyApple;
}
