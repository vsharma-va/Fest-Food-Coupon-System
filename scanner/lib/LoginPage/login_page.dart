import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scanner/HomePage/home_page.dart';
import 'package:scanner/comm/communicate.dart';
import 'package:scanner/components/common_button.dart';
import 'package:scanner/components/common_gradient_text.dart';
import 'package:scanner/components/common_snack_bar.dart';
import 'package:scanner/components/common_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var vendorAuthKeyController = TextEditingController();

  void attemptLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (vendorAuthKeyController.text == "") {
      context.showCommonSnackBar(message: "Please enter a valid auth code");
    } else {
      var response = checkAuthState(vendorAuthKeyController.text.toUpperCase());
      response.then((value) {
        var jsonValue = json.decode(value.body);
        log(jsonValue['status'].toString());
        if (jsonValue['status'] == '200') {
          prefs.setString(
              "vendorName", "${jsonValue['detail']['userState']['userName']}");
          prefs.setString("vendorAuthKey",
              "${jsonValue['detail']['userState']['vendorAuthKey']}");
          context.showCommonSnackBar(
              message: "Login Success!",
              backgroundColor: const Color.fromRGBO(102, 187, 106, 1));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        vendorAuthKey: jsonValue['detail']['authState']
                            ['vendorAuthKey'],
                        vendorName: jsonValue['detail']['authState']
                            ['userName'],
                        balance: jsonValue['detail']['vendorState']['balance'],
                        numberOfCouponsScanned: jsonValue['detail']
                            ['vendorState']['numberOfCouponsScanned'],
                      )));
        } else if (jsonValue['status'] == '401') {
          context.showCommonSnackBar(message: "(401) ${jsonValue['detail']}");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Center(
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: GradientText(
                      "LOGIN",
                      50,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: CommonTextField(
                        controller: vendorAuthKeyController,
                        labelText: "Vendor Authorization Key",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CommonButton(
                      onPressed: attemptLogin,
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // TextField(
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: "Vendor Authorization Code",
              //   ),
              // ),
            ),
          ),
        ),
      ),
    );
  }
}
