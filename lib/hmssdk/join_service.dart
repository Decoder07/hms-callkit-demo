//Dart imports
import 'dart:convert';

//Package imports
import 'package:http/http.dart' as http;

Future<String> getAuthToken({required String roomId}) async {
  Uri endPoint = Uri.parse(
      "https://prod-in2.100ms.live/hmsapi/decoder.app.100ms.live/api/token");
  http.Response response = await http.post(endPoint,
      body: {'user_id': "Test User", 'room_id': roomId, 'role': "host"});
  var body = json.decode(response.body);
  return body['token'];
}
