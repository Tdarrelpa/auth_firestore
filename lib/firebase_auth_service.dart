import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService 
{
  FirebaseAuth? _auth = FirebaseAuth.instance;

  Future<User?> register(String email, String password) async 
  {
    try 
    {
      UserCredential uc = await _auth!.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return uc.user;
    } 
    catch (e) 
    {
      stderr.write("Terjadi Kesalahan saat registrasi: $e");
      return null;  
    }
  }
  
  Future<User?> login(String email, String password) async 
  {
    try 
    {
      UserCredential uc = await _auth!.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return uc.user;
    } 
    catch (e) 
    {
      stderr.write('Error login: $e');
      return null;
    }
  }

  Future<void> logout() async => await _auth!.signOut();

  Stream<User?> get userChanges => _auth!.authStateChanges();

  void dispose(){_auth = null;}
}