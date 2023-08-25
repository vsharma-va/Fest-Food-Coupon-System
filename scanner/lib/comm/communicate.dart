import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:scanner/const_value.dart' as constValue;

Future<http.Response> checkAuthState(String vendorAuthKey) async {
  final response = await http.post(
    Uri.parse("${constValue.apiUri}/api/vendor/login"),
    headers: {
      'ContentType': 'application/json',
    },
    body: jsonEncode({
      'vendorAuthKey': vendorAuthKey,
    }),
  );
  return response;
}

Future<http.Response> scanCode(
    String code, String vendorAuthKey, String vendorName) async {
  final response = await http.post(
    Uri.parse("${constValue.apiUri}/api/vendor/scan"),
    headers: {
      'ContentType': 'application/json',
    },
    body: jsonEncode({
      'vendorAuthKey': vendorAuthKey,
      'vendorName': vendorName,
      'couponCode': code,
    }),
  );
  return response;
}
