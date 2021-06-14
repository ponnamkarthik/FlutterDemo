import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _phoneEditController = TextEditingController();

  void _signIn() {
    String phone = _phoneEditController.text;
    print(phone);
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's get started",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16,),
                Text(
                  "Welcome back, we missed you.",
                  style: TextStyle(
                    fontSize: 38,
                  ),
                ),
                SizedBox(height: 48,),
                TextField(
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
              ],
            ),
            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                _signIn();
              },
              child: Container(
                width: double.infinity,
                margin:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "Sign In",
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
