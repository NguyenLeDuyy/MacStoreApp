import 'package:firebase_auth/firebase_auth.dart';

class AuthController{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> registerNewUser(String email, String fullname, String password) async {
    String res = 'something went wrong';

    try {
      //We want to create the user first in the authentication tab and then cloud firestore


    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    res = 'success';
    }
    catch (e){

    }

    return res;
  }
}