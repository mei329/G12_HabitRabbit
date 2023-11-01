import 'package:flutter/material.dart';

import 'package:g12/screens/page_material.dart';

class VideoPage extends StatefulWidget {
  final Map arguments;

  const VideoPage({super.key, required this.arguments});

  @override
  VideoPageState createState() => VideoPageState();
}

class VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSet.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                //TODO: Change to video name
                Image.asset(
                  "assets/videos/${widget.arguments['item']}.gif",
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        icon: const Icon(Icons.close),
                        color: ColorSet.iconColor,
                        tooltip: "關閉",
                        onPressed: () => Navigator.of(context).pop())),
              ],
            ),
            // TODO: Get description of item
            Column(
              children: [
                const SizedBox(height: 10),
                ListTile(
                    contentPadding:
                        const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 0.0),
                    title: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          widget.arguments['item'],
                          style: const TextStyle(
                              color: ColorSet.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 10),
                        )),
                    subtitle: Column(
                      children: [
                        Row(
                          children: const [
                            Text(
                              " \u2022  轉轉肩膀",
                              style: TextStyle(
                                  color: ColorSet.textColor, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: const [
                            Text(
                              " \u2022  扭扭脖子",
                              style: TextStyle(
                                  color: ColorSet.textColor, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: const [
                            Text(
                              " \u2022  動動嘴巴",
                              style: TextStyle(
                                  color: ColorSet.textColor, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
