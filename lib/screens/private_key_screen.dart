import 'package:auric/common/heading_text.dart';
import 'package:auric/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivateKeyScreen extends StatefulWidget {
  const PrivateKeyScreen({super.key});

  @override
  State<PrivateKeyScreen> createState() => _PrivateKeyScreenState();
}

class _PrivateKeyScreenState extends State<PrivateKeyScreen> {
  final formKey = GlobalKey<FormState>();
  final keyController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool obscureText = true;
  bool isProcessing = false;

  @override
  void dispose() {
    keyController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      try {
        setState(() {
          isProcessing = true;
        });
        final storage = FlutterSecureStorage();
        await storage.write(
          key: '${supabase.auth.currentUser!.id}_privateKey',
          value: keyController.text,
        );
        Get.to(() => const HomeScreen());
      } on PlatformException catch (err) {
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: Text("Private Key"),
              description: Text(
                err.message ??
                    "Unable to securely store the Private key locally on your device",
              ),
            ),
          );
        }
      } catch (err) {
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: Text("Private Key"),
              description: Text(err.toString()),
            ),
          );
        }
      } finally {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text("Secure")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeadingText(text: "Set your private key"),
                Text(
                  "Your private key keeps your financial data encrypted and protected. Even we can’t access your entries only your key can unlock them. Save it securely; it’s the foundation of your privacy.",
                ),
                ShadInputFormField(
                  controller: keyController,
                  obscureText: obscureText,
                  autovalidateMode: AutovalidateMode.onUserInteraction,

                  validator: (value) {
                    if (value.isEmpty) {
                      return "Private key is required";
                    } else if (value.length < 8) {
                      return 'Private key must be at least 8 characters';
                    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Include at least one uppercase letter';
                    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Include at least one number';
                    }
                    return null;
                  },
                  placeholder: Text("Key"),
                  trailing: ShadIconButton.ghost(
                    height: 24,
                    width: 24,
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: Icon(
                      obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: isProcessing
                          ? ShadProgress(minHeight: 5)
                          : ShadButton(
                              onPressed: () async {
                                await submit();
                              },
                              child: Text("Continue"),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
