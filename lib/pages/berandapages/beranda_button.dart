import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class BerandaButton extends StatefulWidget {
  final VoidCallback onDetailPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onSelesaiPressed;
  final bool disableDetailButton;
  final bool fromHistory; // ⬅️ Tambahan

  const BerandaButton({
    Key? key,
    required this.onDetailPressed,
    required this.onEditPressed,
    required this.onSelesaiPressed,
    this.disableDetailButton = false,
    this.fromHistory = false, // ⬅️ Default-nya false
  }) : super(key: key);

  @override
  State<BerandaButton> createState() => _BerandaButtonState();
}

class _BerandaButtonState extends State<BerandaButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!widget.disableDetailButton)
          ElevatedButton.icon(
            onPressed: widget.onDetailPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[200],
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              LucideIcons.fileText,
              color: Colors.black,
              size: 24,
            ),
            label: Text(
              "Detail",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: widget.onSelesaiPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(
            widget.fromHistory
                ? LucideIcons.clipboardList // 📝 Icon rekap
                : LucideIcons.checkCheck, // ✅ Icon selesaikan
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            widget.fromHistory ? "Rekap" : "Selesaikan",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
