import 'package:auric/screens/home_screen.dart';
import 'package:auric/screens/private_key_screen.dart';
import 'package:auric/screens/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final supabase = Supabase.instance.client;
  bool isRegistering = false;
  bool showPassword = false;
  bool inProcess = false;
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? validateEmail(String? value) {
    const pattern =
        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }

  Future<void> signUp() async {
    try {
      setState(() {
        inProcess = true;
      });
      var response = await supabase.auth.signUp(
        password: passwordController.text,
        email: emailController.text,
        data: {"username": usernameController.text},
      );
      if (response.user!.identities!.isEmpty) {
        throw Exception('Email is already used.');
      }
      Get.to(() => VerifyEmailScreen(email: emailController.text));
    } on AuthApiException catch (err) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text("Registeration Failed"),
            description: Text(err.message),
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text("Registeration Failed"),
            description: Text(err.toString()),
          ),
        );
      }
    } finally {
      setState(() {
        inProcess = false;
      });
    }
  }

  Future<void> signIn() async {
    try {
      setState(() {
        inProcess = true;
      });
      AuthResponse res = await supabase.auth.signInWithPassword(
        password: passwordController.text,
        email: emailController.text,
      );
      final storage = FlutterSecureStorage();
      String privateKeyID = '${res.user!.id}_privateKey';
      String? privateKey = await storage.read(key: privateKeyID);
      if (privateKey != null) {
        Get.offAll(() => const HomeScreen());
      } else {
        Get.to(() => const PrivateKeyScreen());
      }
    } on AuthApiException catch (err) {
      if (err.code == "email_not_confirmed") {
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: Text("Email Verification"),
              description: Text(
                "Your email was not verified, verification OTP was send again please verify your email",
              ),
            ),
          );
        }
        String email = emailController.text.trim();
        if (email.isEmpty) {
          if (mounted) {
            ShadToaster.of(context).show(
              ShadToast(
                title: Text("Email required"),
                description: Text(
                  "Please enter your email to resend verification.",
                ),
              ),
            );
          }
          return;
        }
        await supabase.auth.resend(email: email, type: OtpType.signup);
        Get.to(() => VerifyEmailScreen(email: email));
      } else if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text("Log in failed"),
            description: Text("${err.code} ${err.message}"),
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text("Log in failed"),
            description: Text(err.toString()),
          ),
        );
      }
    } finally {
      setState(() {
        inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(isRegistering ? "Register" : "Login")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                  Text(
                    "Your account keeps your data synced securely across devices.",
                    textAlign: TextAlign.center,
                  ),
                  if (isRegistering)
                    ShadInputFormField(
                      key: ValueKey('username_field'),
                      id: "username",
                      enabled: !inProcess,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      controller: usernameController,
                      placeholder: Text("Username"),
                      validator: (value) {
                        if (inProcess) {
                          return null;
                        } else if (value.isEmpty) {
                          return "Username is required";
                        } else if (value.length < 4) {
                          return "Minimum 4 length username required";
                        }
                        return null;
                      },
                    ),
                  ShadInputFormField(
                    key: ValueKey('email_field'),
                    id: "email",
                    enabled: !inProcess,
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (inProcess) {
                        return null;
                      } else if (validateEmail(value) != null) {
                        return validateEmail(value);
                      } else if (value.isEmpty) {
                        return "Email is required";
                      }
                      return null;
                    },
                    placeholder: Text("Email"),
                  ),
                  ShadInputFormField(
                    key: ValueKey('password_field'),
                    id: "password",
                    enabled: !inProcess,
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    controller: passwordController,
                    obscureText: !showPassword,
                    placeholder: Text("Password"),
                    trailing: ShadIconButton.ghost(
                      height: 24,
                      width: 24,
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      icon: Icon(
                        showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                    ),

                    validator: (value) {
                      if (inProcess) {
                        return null;
                      } else if (value.isEmpty) {
                        return "Password is required";
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Include at least one uppercase letter';
                      } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Include at least one number';
                      }
                      return null;
                    },
                  ),
                  if (isRegistering)
                    Row(
                      children: [
                        Expanded(
                          child: inProcess
                              ? ShadProgress(minHeight: 5)
                              : ShadButton(
                                  onPressed: inProcess
                                      ? null
                                      : () async {
                                          await signUp();
                                        },
                                  child: Text("Register"),
                                ),
                        ),
                      ],
                    ),
                  if (isRegistering)
                    ShadButton.link(
                      onPressed: inProcess
                          ? null
                          : () {
                              setState(() {
                                isRegistering = false;
                                emailController.clear();
                                usernameController.clear();
                                passwordController.clear();
                              });
                            },
                      child: Text("Already have an account? Log in"),
                    ),
                  if (!isRegistering)
                    Row(
                      children: [
                        Expanded(
                          child: inProcess
                              ? ShadProgress(minHeight: 5)
                              : ShadButton(
                                  onPressed: inProcess
                                      ? null
                                      : () async {
                                          await signIn();
                                        },
                                  child: Text("Log in"),
                                ),
                        ),
                      ],
                    ),
                  if (!isRegistering)
                    ShadButton.link(
                      onPressed: inProcess
                          ? null
                          : () {
                              setState(() {
                                isRegistering = true;
                                usernameController.clear();
                                emailController.clear();
                                passwordController.clear();
                              });
                            },
                      child: Text("Don’t have an account? Create one"),
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
