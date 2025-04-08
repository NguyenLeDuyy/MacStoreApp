import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> registerNewUser(
    String email,
    String fullname,
    String password,
  ) async {
    String res = 'something went wrong';

    try {
      //We want to create the user first in the authentication tab and then cloud firestore

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('buyers').doc(userCredential.user!.uid).set({
        'fullName': fullname,
        'email': email,
        'profileImage': "",
        'uid': userCredential.user!.uid,
        'pinCode': "",
        'locality': '',
        'city': '',
        'state': "",
      });

      res = 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        res = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  //LOGIN USER
  ///
  Future<String> loginUser(String email, String password) async {
    String res = 'Something went wrong';

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      res = 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        res = 'Wrong password provided for that user.';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
