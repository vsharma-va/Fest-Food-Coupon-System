import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scanner/LoginPage/login_page.dart';
import 'package:scanner/comm/communicate.dart';
import 'package:scanner/components/common_button.dart';
import 'package:scanner/components/common_gradient_text.dart';
import 'package:scanner/components/common_snack_bar.dart';
import 'package:scanner/components/common_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String? vendorName;
  final String? vendorAuthKey;
  int balance;
  int numberOfCouponsScanned;
  HomePage(
      {super.key,
      required this.vendorName,
      required this.vendorAuthKey,
      required this.balance,
      required this.numberOfCouponsScanned});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var code = TextEditingController();

  void checkCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? vendorAuthKey = prefs.getString("vendorAuthKey");
    final String? vendorName = prefs.getString("vendorName");

    if (vendorAuthKey == null || vendorName == null) {
      context.showCommonSnackBar(message: "Auth State Lost");
      logoutVendor();
    } else {
      if (code.text == "") {
        context.showCommonSnackBar(message: "Please enter a valid coupon code");
      } else {
        var response =
            scanCode(code.text.toLowerCase(), vendorAuthKey, vendorName);
        response.then(
          (value) {
            var jsonValue = json.decode(value.body);
            if (jsonValue['status'] == '200') {
              context.showCommonSnackBar(
                  message:
                      "(${jsonValue['status']}) ${jsonValue['detail']['msg']}",
                  backgroundColor: const Color.fromRGBO(102, 187, 106, 1));
              setState(() {
                widget.balance = jsonValue['detail']['vendorState']['balance'];
                widget.numberOfCouponsScanned = jsonValue['detail']
                    ['vendorState']['numberOfCouponsScanned'];
              });
            } else if (jsonValue['status'] == '403') {
              context.showCommonSnackBar(
                  message: "(${jsonValue['status']}) ${jsonValue['detail']}");
              logoutVendor();
            } else if (jsonValue['status'] == '422') {
              context.showCommonSnackBar(
                  message: "(${jsonValue['status']}) ${jsonValue['detail']}");
            } else if (jsonValue['status'] == '400') {
              context.showCommonSnackBar(
                  message: "(${jsonValue['status']} ${jsonValue['detail']}}");
            }
          },
        );
      }
    }
  }

  void refreshState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? vendorAuthKey = prefs.getString("vendorAuthKey");
    final String? vendorName = prefs.getString("vendorName");
    if (vendorAuthKey == null || vendorName == null) {
      context.showCommonSnackBar(message: "Auth State Lost");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } else {
      final response = checkAuthState(vendorAuthKey);
      response.then((value) {
        var jsonValue = json.decode(value.body);
        if (jsonValue['status'] == '200') {
          setState(() {
            widget.balance = jsonValue['detail']['vendorState']['balance'];
            widget.numberOfCouponsScanned =
                jsonValue['detail']['vendorState']['numberOfCouponsScanned'];
          });

          context.showCommonSnackBar(
              message: "All Good!",
              backgroundColor: const Color.fromRGBO(102, 187, 106, 1));
        } else {
          context.showCommonSnackBar(message: "Auth State Lost");
        }
      });
    }
  }

  void logoutVendor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("vendorAuthKey");
    prefs.remove("vendorName");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox.expand(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      child: GradientText(
                        "WELCOME ${widget.vendorName}!",
                        40,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: GradientText(
                            "Balance: ${widget.balance}",
                            20,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: GradientText(
                            "Coupons Scanned: ${widget.numberOfCouponsScanned}",
                            20,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CommonTextField(
                                controller: code,
                                labelText: "Enter the food coupon code"),
                            const SizedBox(height: 30),
                            CommonButton(
                              onPressed: checkCode,
                              child: const Text("Scan",
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: refreshState,
                        child: const Text("Refresh"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
