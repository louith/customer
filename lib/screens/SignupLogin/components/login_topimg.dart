import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../components/constants.dart';

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Log In".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: defaultPadding),
        Row(
          children: [
            Expanded(
              flex: 8,
              child: SvgPicture.asset(
                'assets/svg/login.svg',
                height: 260,
                width: 280,
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}
