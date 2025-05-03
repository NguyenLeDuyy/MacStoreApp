import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReuseableTextWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final VoidCallback? onTap;

  const ReuseableTextWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              subTitle,
              style: GoogleFonts.roboto(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
