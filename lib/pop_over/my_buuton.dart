import 'package:flutter/material.dart';
import 'package:flutter_application_33/pop_over/pop_over.dart';

import 'package:popover/popover.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPopover(
        context: context,
        bodyBuilder: (context) => Menu(),
        width: 200,
        height: 150,
        backgroundColor: Colors.white,
        direction: PopoverDirection.bottom,
      ),
      child: const Icon(
        Icons.more_vert,
        size: 30,
        color: Colors.white,
      ),
    );
  }
}
