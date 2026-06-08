import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:raspberry_lights_controller/providers/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network.g.dart';

enum _ConnectionsInfoState {
  empty,
  available,
}

class ConnectionInfo {
  final _ConnectionsInfoState _state;
  late final String? _host;
  late final int? _port;

  ConnectionInfo._({
    required this._state,
    required this._host,
    required this._port,
  }) : assert(
         _state == _ConnectionsInfoState.available
             ? _host != null && _port != null
             : _host == null && _port == null,
         'host/port must be non-null if "available" and vice-versa',
       );

  ConnectionInfo.empty()
    : this._(state: _ConnectionsInfoState.empty, host: null, port: null);
  ConnectionInfo.available({
    required String host,
    required int port,
  }) : this._(state: _ConnectionsInfoState.available, host: host, port: port);

  (String, int)? get info =>
      _state == _ConnectionsInfoState.available ? (_host!, _port!) : null;
}

@riverpod
class Host extends _$Host {
  static const hostIpKey = 'hostIP';
  static const hostPortKey = 'hostPort';

  @override
  ConnectionInfo? build() {
    final preferences = ref.watch(sharedPreferencesProvider).value;
    if (preferences == null) {
      log('preferences not ready yet');
      return null;
    }

    final ip = preferences.getString(hostIpKey);
    final port = preferences.getInt(hostPortKey);

    log('preferences -> ip: $ip, port: $port');

    if (ip != null && port != null) {
      return ConnectionInfo.available(host: ip, port: port);
    } else {
      return ConnectionInfo.empty();
    }
  }

  Future<void> setHostUrl((String, int) host) async {
    final preferences = await ref.read(sharedPreferencesProvider.future);

    await preferences.setString(hostIpKey, host.$1);
    await preferences.setInt(hostPortKey, host.$2);

    state = ConnectionInfo.available(host: host.$1, port: host.$2);
  }
}

@riverpod
class NetworkClient extends _$NetworkClient {
  @override
  Dio build() {
    final client = Dio();
    final host = ref.watch(hostProvider);
    log(host?.info != null ? 'host is set' : 'host not set');

    if (host != null && host.info != null) {
      final info = host.info!;
      client.options.baseUrl = 'http://${info.$1}:${info.$2}/';
    }

    return client;
  }
}
