import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialapp_studio/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController _phoneEditController = TextEditingController();
  TextEditingController _otpEditController = TextEditingController();

  bool smsSent = false;
  String verificationId = "";

  Future<void> _signIn() async {
    String phone = _phoneEditController.text;
    print("+91$phone");

    await auth.verifyPhoneNumber(
      phoneNumber: "+91$phone",
      verificationCompleted: (PhoneAuthCredential credential) {
        print("Verification Completed");
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Sent OTP");
        this.verificationId = verificationId;
        setState(() {
          smsSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _verifyOTP() async {
    // verification code
    String smsCode = _otpEditController.text;

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    // Sign the user in (or link) with the credential
    UserCredential userCredential = await auth.signInWithCredential(credential);

    if (userCredential.user == null) {
      print("User not logged in");
    } else {
      print("user is logged in");
      print(userCredential.user?.phoneNumber ?? "Phone number is null");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's get started",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Welcome back, we missed you.",
                      style: TextStyle(
                        fontSize: 38,
                      ),
                    ),
                    SizedBox(
                      height: 48,
                    ),
                    TextField(
                      enabled: !smsSent,
                      controller: _phoneEditController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        hintText: "Phone number",
                      ),
                      cursorColor: Colors.purpleAccent,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 24),
                    if (smsSent)
                      TextField(
                        controller: _otpEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white24,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white24,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white24,
                            ),
                          ),
                          hintText: "OTP",
                        ),
                        cursorColor: Colors.purpleAccent,
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                if (smsSent) {
                  _verifyOTP();
                } else {
                  _signIn();
                }
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    smsSent ? "Verify" : "Sign In",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF191720),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
