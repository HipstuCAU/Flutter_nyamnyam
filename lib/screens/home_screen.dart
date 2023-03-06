import 'package:flutter/material.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: NyamColors.customGrey,
                  size: 35,
                ),
                label: const Text(
                  "서울캠퍼스",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings),
              color: NyamColors.customGrey,
              iconSize: 25,
            )
          ],
        ),
      ),
    );
  }
}
