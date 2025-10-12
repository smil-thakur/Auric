import 'package:auric/common/heading_text.dart';
import 'package:auric/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool inProcess = false;
  final supabase = Supabase.instance.client;
  String otp = "";

  Future<void> verifyUser() async {
    try {
      setState(() {
        inProcess = true;
      });
      await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: widget.email,
        token: otp,
      );
      Get.offAll(() => const HomeScreen());
    } catch (err) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text('Email Verification'),
            description: Text("Something went wrong ${err.toString()}"),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            spacing: 24,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeadingText(text: "Verify Email"),
              Text(
                "A verfication email is send to your emailid, please provide the OTP in the email to verify the email",
              ),
              ShadInputOTPFormField(
                maxLength: 6,
                onChanged: (value) {
                  setState(() {
                    otp = value;
                  });
                },
                description: const Text('Enter your OTP.'),
                validator: (v) {
                  if (v.contains(' ')) {
                    return 'Fill the whole OTP code';
                  }
                  return null;
                },
                children: [
                  ShadInputOTPGroup(
                    children: [
                      ShadInputOTPSlot(),
                      ShadInputOTPSlot(),
                      ShadInputOTPSlot(),
                    ],
                  ),
                  Icon(size: 24, LucideIcons.dot),
                  ShadInputOTPGroup(
                    children: [
                      ShadInputOTPSlot(),
                      ShadInputOTPSlot(),
                      ShadInputOTPSlot(),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: inProcess
                        ? ShadProgress(minHeight: 5)
                        : ShadButton(
                            onPressed: inProcess
                                ? null
                                : () async {
                                    await verifyUser();
                                  },
                            child: Text("verify"),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
