import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tesis/home.dart';
import 'package:tesis/provider/google_sign_in.dart';
import 'package:tesis/user/user_home.dart';

import 'login.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          UserHelper.saveUser(snapshot.data!);
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                final userDoc = snapshot.data;
                final user = userDoc!.data();
                if ((user as Map<String, dynamic>)['role'] == 'admin') {
                  return const Home();
                } else {
                  return const UserHome();
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Algo ha salido mal!'));
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
