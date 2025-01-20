import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.size,
    this.title,
  });

  final Size size;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: size.height * 0.15,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              height: 50,
              width: 100,
              child: Image.asset(
                "assets/images/logo3.png",
                fit: BoxFit.contain,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                title ?? "",
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Colors.white,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
