import 'package:dio/dio.dart';
import 'package:raspberry_lights_controller/providers/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network.g.dart';

@riverpod
class Host extends _$Host {
  static const hostIpKey = "hostIP";
  static const hostPortKey = "hostPort";

  @override
  (String, int)? build() {
    final preferences = ref.watch(sharedPreferencesProvider).valueOrNull;

    final ip = preferences?.getString(hostIpKey);
    final port = preferences?.getInt(hostPortKey);
    if (ip != null && port != null) {
      return (ip, port);
    } else {
      return null;
    }
  }

  void setHostUrl((String, int) host) async {
    final preferences = await ref.read(sharedPreferencesProvider.future);

    await preferences.setString(hostIpKey, host.$1);
    await preferences.setInt(hostPortKey, host.$2);

    state = host;
  }
}

@riverpod
class NetworkClient extends _$NetworkClient {
  @override
  Dio build() {
    final client = Dio();
    final host = ref.watch(hostProvider);

    if (host != null) {
      client.options.baseUrl = 'http://${host.$1}:${host.$2}/';
    }

    return client;
  }
}
