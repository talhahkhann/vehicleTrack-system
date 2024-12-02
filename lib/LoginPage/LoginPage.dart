import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vehitrack/main.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _rememberMe = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  void _saveRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      prefs.setString('email', _emailController.text.trim());
      prefs.setString('password', _passwordController.text.trim());
    } else {
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle access management',
          style: TextStyle(
            color: Colors.indigo[500],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 63, 81, 181),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Smart Access Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 180,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 110,
                    color: Color.fromARGB(255, 241, 242, 245),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: _isLoggedIn ? _buildSuccessAnimation() : _buildLoginForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildEmailTextField(),
              SizedBox(height: 16),
              _buildPasswordTextField(),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  Text('Remember me'),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_isLoggedIn) {
                    // Logout functionality
                    _auth.signOut();
                    _clearForm();
                  } else {
                    // Login functionality
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();

                    try {
                      UserCredential userCredential =
                          await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // If login is successful, save "Remember Me" status and trigger the success animation.
                      _saveRememberMe();
                      setState(() {
                        _isLoggedIn = true;
                      });
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        // Handle different authentication errors and display appropriate messages.
                        if (e.code == 'user-not-found') {
                          _errorMessage = 'No user found for that email.';
                        } else if (e.code == 'wrong-password') {
                          _errorMessage =
                              'Wrong password provided for that user.';
                        } else {
                          _errorMessage =
                              'Login failed. Please try again later.';
                        }
                      });
                    } catch (e) {
                      setState(() {
                        // Handle other errors, e.g., display a generic error message.
                        _errorMessage =
                            'An error occurred. Please try again later.';
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  shadowColor: Colors.blue,
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showPinDialog();
                },
                child: Text('Login with PIN'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTextField() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: _showEmailIcon
          ? Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showEmailIcon = false;
                      });
                    },
                    child: Container(
                      height: 48,
                      child: Icon(Icons.email,
                          color: Color.fromARGB(255, 249, 251, 253)),
                    ),
                  ),
                ),
              ],
            )
          : TextField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
    );
  }

  Widget _buildPasswordTextField() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: _showPasswordIcon
          ? Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPasswordIcon = false;
                      });
                    },
                    child: Container(
                      height: 48,
                      child: Icon(Icons.lock,
                          color: const Color.fromARGB(255, 238, 241, 243)),
                    ),
                  ),
                ),
              ],
            )
          : TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
              ),
              obscureText: true,
            ),
    );
  }

  bool _showEmailIcon = true;
  bool _showPasswordIcon = true;

  Widget _buildSuccessAnimation() {
    return Center(
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 7,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add navigation code here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(title: 'Your App Title'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 5,
                shadowColor: Colors.green,
              ),
              child: Text('Smile Please'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter PIN'),
          content: PinCodeTextField(
            appContext: context,
            length: 4,
            onChanged: (pin) {
              setState(() {
                _pinController.text = pin;
              });
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate the PIN here
                String enteredPin = _pinController.text.trim();
                String correctPin = '1234'; // Change this to your desired PIN

                if (enteredPin == correctPin) {
                  Navigator.of(context).pop(); // Close the dialog
                  // Perform any additional actions related to PIN authentication
                  setState(() {
                    _isLoggedIn = true;
                  });
                } else {
                  // Incorrect PIN, you can show an error message or take appropriate action
                  print('Incorrect PIN');
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _pinController.clear();
    setState(() {
      _rememberMe = false;
      _errorMessage = '';
      _isLoggedIn = false;
      _showEmailIcon = true;
      _showPasswordIcon = true;
    });
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 4,
      size.height - 100,
      size.width / 2,
      size.height - 100,
    );
    path.quadraticBezierTo(
      3 * size.width / 4,
      size.height,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
