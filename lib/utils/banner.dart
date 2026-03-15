import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fast_api_and_flutter/provider/connectivity_check_provider.dart';

class InternetBanner extends StatefulWidget {
  const InternetBanner({super.key});

  @override
  State<InternetBanner> createState() => _InternetBannerState();
}

class _InternetBannerState extends State<InternetBanner> {
  bool showOnline = false;
  bool? lastStatus;

  @override
  Widget build(BuildContext context) {
    final internet = Provider.of<InternetProvider>(context);
    final isConnected = internet.isConnected;

    if (lastStatus != null && lastStatus == false && isConnected == true) {
      showOnline = true;

      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showOnline = false;
          });
        }
      });
    }

    lastStatus = isConnected;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },

      child: !isConnected
          ? _banner(
              key: const ValueKey("offline"),
              color1: const Color(0xFFEF4444),
              color2: const Color(0xFFDC2626),
              icon: Icons.wifi_off,
              text: "You are Offline",
            )
          : showOnline
          ? _banner(
              key: const ValueKey("online"),
              color1: const Color(0xFF22C55E),
              color2: const Color(0xFF16A34A),
              icon: Icons.wifi,
              text: "Back Online",
            )
          : const SizedBox(),
    );
  }

  Widget _banner({
    required Key key,
    required Color color1,
    required Color color2,
    required IconData icon,
    required String text,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
