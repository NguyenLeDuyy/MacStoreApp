import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_web/controllers/auth_controller.dart';
import 'package:app_web/views/screens/authentication_screens/login_screen.dart';

class RegisterScreenAdmin extends StatefulWidget {
  static const String id = 'register_admin';

  const RegisterScreenAdmin({super.key});


  @override
  State<RegisterScreenAdmin> createState() => _RegisterScreenAdminState();
}

class _RegisterScreenAdminState extends State<RegisterScreenAdmin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthControllerForAdmin _authController = AuthControllerForAdmin();
  bool _isLoading = false;
  late String fullName;

  late String email;

  late String password;

  bool _isObscure = true;

  registerAdmin() async {
  BuildContext localContext = context;
  setState(() {
    _isLoading = true;
  });

  String res = await _authController.registerNewAdmin(
    email,
    fullName,
    password,
  );
  if (res == 'success') {
    Future.delayed(Duration.zero, () {
        Navigator.push(
          localContext,
          MaterialPageRoute(
            builder: (context) {
              return LoginScreenAdmin();
            },
          ),
        );
        ScaffoldMessenger.of(localContext).showSnackBar(
          const SnackBar(
            content: Text('Congratulation account has been created for you'),
          ),
        );
      }
    );
  } else {
    setState(() {
        _isLoading = false;
      }
    );

    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res)));
    }
  );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create Your Account For Admin",
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: Color(0xFF0d120E),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    'To Explore the world exclusives',
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: Color(0xFF0d120E),
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),

                  Image.asset(
                    'assets/images/Illustration.png',
                    width: 200,
                    height: 200,
                  ),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Full name',
                      style: GoogleFonts.getFont(
                        'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  TextFormField(
                    onChanged: (value) {
                      fullName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter your name";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: "Enter your full name",
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/user.jpeg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Email',
                      style: GoogleFonts.getFont(
                        'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  TextFormField(
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: "Enter your email",
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/email.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Password',
                      style: GoogleFonts.getFont(
                        'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  TextFormField(
                    obscureText: _isObscure,
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: "Enter your password",
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/password.png',
                          width: 20,
                          height: 20,
                        ),
                      ),

                      suffixIcon: IconButton(onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      }, icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility,),),
                    ),
                  ),

                  SizedBox(height: 20),

                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        registerAdmin();
                      }
                    },
                    child: Container(
                      width: 319,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF102DE1), Color(0xCC0D6EFF)],
                        ),
                      ),
                      child: Center(
                        child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Sign up',
                          style: GoogleFonts.getFont(
                            'Lato',
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginScreenAdmin();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.roboto(
                            color: Color(0xFF102DE1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}