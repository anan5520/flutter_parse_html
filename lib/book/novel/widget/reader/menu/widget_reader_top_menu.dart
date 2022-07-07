import 'package:flutter/material.dart';

class NovelTopMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: InkWell(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
