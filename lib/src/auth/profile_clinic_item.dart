import 'package:flutter/material.dart';

class ProfileClinicItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const ProfileClinicItem({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFF131314)),
        elevation: MaterialStateProperty.all<double>(0),
        side: MaterialStateProperty.all<BorderSide>(
          BorderSide(
            color:
                isSelected ? const Color(0xFF40A1FB) : const Color(0xFF454545),
            width: isSelected ? 2 : 1,
          ),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Causten-Medium',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}
