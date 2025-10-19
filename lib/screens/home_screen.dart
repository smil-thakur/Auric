import 'package:auric/common/amount_send_button.dart';
import 'package:auric/common/icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  final storage = FlutterSecureStorage();
  IconData? btnIcon;
  void onIconSelected(IconData icon) {
    setState(() {
      btnIcon = icon;
    });
  }

  String? userPrivateKey;

  void getPrivateKey() async {
    try {
      userPrivateKey = await storage.read(
        key: "${supabase.auth.currentUser?.id}_privateKey",
      );
    } catch (err) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text("PrivateKey error"),
            description: Text(
              "Unable to fetch your private key, please try again",
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    getPrivateKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [IconPicker(onIconSelect: onIconSelected)],
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: ShadTheme.of(context).colorScheme.card,
          border: Border(
            top: BorderSide(
              width: 1,
              color: ShadTheme.of(context).colorScheme.border,
            ),
          ),
        ),
        height: 100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Row(
            spacing: 16,
            children: [
              Expanded(
                child: ShadInputFormField(
                  id: 'amount',
                  placeholder: const Text('Enter Amount'),
                  validator: (v) {
                    if (v.length < 2) {
                      return 'Username must be at least 2 characters.';
                    }
                    return null;
                  },
                ),
              ),
              AmountSendButton(icon: btnIcon ?? LucideIcons.indianRupee),
            ],
          ),
        ),
      ),
    );
  }
}
