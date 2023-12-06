import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Utilities/SecureStorage.dart';

class SocketConstants {
static late IO.Socket? socket;
  static Future<bool> initSocket() async {
    String? agentAccessToken = await MyStorage.getAccessToken();
    socket = IO.io(
      'http://134.122.28.251:4545',
      <String, dynamic>{
        'query': {'token': agentAccessToken},
        'transports': ['websocket'],
      },
    );
    // Check if the socket is properly initialized
    bool isSocketInitialized = socket != null && agentAccessToken != null;
    return isSocketInitialized;
  }
}