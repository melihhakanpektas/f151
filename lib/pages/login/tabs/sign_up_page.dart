import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f151/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>(); // Form key

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey, // Assigning form key
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                minRadius: 50,
                backgroundColor: kAppBarBackgroundColor,
                child: Icon(
                  Icons.person,
                  size: 100,
                ),
              ),
              const SizedBox(height: 10),
              // full name
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Ad Soyad',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı ve soyadınızı girin.';
                  }
                  if (!value.contains(' ')) {
                    return 'Lütfen tam adınızı girin (Ad ve soyad arasında boşluk olmalıdır).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir email adresi girin.';
                  }
                  if (!RegExp(
                          r'^[\w-]+(\.[\w-]+)*@([a-z\d-]+(\.[a-z\d-]+)*\.)+[a-z]{2,}$')
                      .hasMatch(value)) {
                    return 'Lütfen geçerli bir email adresi girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // password
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Şifre',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir şifre girin.';
                  }
                  if (value.length < 6) {
                    return 'Şifreniz en az 6 karakter olmalıdır.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // confirm password
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Şifre Onayla',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifreyi onaylayın.';
                  }
                  if (value != passwordController.text) {
                    return 'Şifreler uyuşmuyor.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    // Validate the form
                    try {
                      // Kayıt işlemi
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      // Firestore'a veri kaydetme işlemi
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set({'name': nameController.text});
                      // Kayıt işlemi başarılı olduğunda yapılacak işlemler
                      Navigator.pop(context);
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        // Şifre zayıf hatası
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Şifre zayıf. Lütfen daha güçlü bir şifre seçin.'),
                          ),
                        );
                      } else if (e.code == 'email-already-in-use') {
                        // Email zaten kullanımda hatası
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Bu email adresi ile daha önce kayıt olunmuş.'),
                          ),
                        );
                      } else if (e.code == 'invalid-email') {
                        // Geçersiz email hatası
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Geçersiz bir email adresi girdiniz.'),
                          ),
                        );
                      } else {
                        // Diğer hata durumları
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Kayıt işlemi sırasında bir hata oluştu.'),
                          ),
                        );
                      }
                    } catch (e) {
                      // Genel hata durumu
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Kayıt işlemi sırasında bir hata oluştu.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
