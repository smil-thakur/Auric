import 'package:flutter/material.dart';

class AmountSendButton extends StatelessWidget {
  final IconData icon;
  const AmountSendButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon),
      ),
    );
  }
}
