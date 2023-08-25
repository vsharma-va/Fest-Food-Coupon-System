import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scanner/HomePage/home_page.dart';
import 'package:scanner/LoginPage/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scanner/comm/communicate.dart' as comm;

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  @override
  void initState() {
    _checkAuthStatus();
    super.initState();
  }

  void _checkAuthStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final response =
    //     comm.checkAuthState("accessToken", "refreshToken", "supabaseId");
    // response.then((value) {
    //   if (value.statusCode == 422) {
    //     final Map parsed = jsonDecode(value.body);
    //     log(parsed.toString());
    //     // Navigator.push(context,
    //     //     MaterialPageRoute(builder: (context) => const LoginPage()));
    //   } else if (value.statusCode == 200) {
    //     final Map parsed = jsonDecode(value.body);
    //   }
    // });

    String? vendorAuthKey = prefs.getString("vendorAuthKey");
    if (vendorAuthKey != null) {
      final response = comm.checkAuthState(vendorAuthKey);
      response.then((value) {
        var jsonValue = json.decode(value.body);
        if (jsonValue['status'] == '200') {
          String? vendorName = prefs.getString("vendorName");
          if (vendorName != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          vendorAuthKey: vendorAuthKey,
                          vendorName: vendorName,
                          balance: jsonValue['detail']['vendorState']
                              ['balance'],
                          numberOfCouponsScanned: jsonValue['detail']
                              ['vendorState']['numberOfCouponsScanned'],
                        )));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          }
        } else if (jsonValue['status'] == '401') {
          prefs.remove("vendorAuthKey");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        }
      });
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
