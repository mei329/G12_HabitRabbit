import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:video_player/video_player.dart';

import 'package:g12/services/Database.dart';
import 'package:g12/services/PlanAlgo.dart';

class ExercisePage extends StatefulWidget {
  final Map arguments;

  const ExercisePage({super.key, required this.arguments});

  @override
  ExercisePageState createState() => ExercisePageState();
}

class ExercisePageState extends State<ExercisePage> {
  String sport = "運動項目";
  late int totalTime;
  int countDown = 6; // 60s
  bool ifStart = false;
  var period = const Duration(seconds: 1);

  /* 計時器時間設定 */
  // 時間格式化，根據總秒數轉換為對應的 hh:mm:ss 格式
  String constructTime(int seconds) {
    //int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return "${formatTime(minute)}:${formatTime(second)}";
    //return formatTime(hour) + ":" + formatTime(minute) + ":" + formatTime(second);
  }

  // 時間格式化，將 0~9 的時間轉換為 00~09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0$timeNum" : timeNum.toString();
  }

  /* 計時器時間設定 */

  /* 播放影片 delete??? */
  //late VideoPlayerController _controller;
  //late Future<void> _initializeVideoPlayerFuture;

  /* 播放影片 delete??? */

  /*  GIF 輪播 */
  late PageController _pageController; //輪播圖 PageView 使用的控制器
  int currentIndex = 0; //當前顯示的索引
  int exerciseItemListLength = 0;

  Widget buildVideoBanner(List videoList) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          //輪播圖片
          buildVideoBannerWidget(videoList),
        ],
      ),
    );
  }

  buildVideoBannerWidget(List videoList) {
    // 懶載入方式構建
    return PageView.builder(
      // 構建每一個子Item的佈局
      itemBuilder: (BuildContext context, int index) {
        return buildPageViewItemWidget(index, videoList);
      },
      controller: _pageController, // 控制器
      itemCount: videoList.length, // 輪播個數 無限輪播 ??
    );
  }

  // 輪播顯示圖片
  buildPageViewItemWidget(int index, List videoList) {
    //return VideoPlayerController.asset('assets/videos/videoTest.mp4');
    return Image.asset(
      videoList[index % videoList.length],
      fit: BoxFit.fill,
    );
  }

  // Get Gif List to play.
  List<String> _getVideoList(List exerciseItem) {
    List exerciseItemList = exerciseItem;
    List<String> videoList = [
      for (int i = 0; i < exerciseItemList.length; i++)
        "assets/videos/${exerciseItem[i]}.gif"
    ];
    videoList.add("assets/images/testPic.gif");
    return videoList;
  }

  // Get exerciseItem name List.
  List _getExerciseItemNameList() {
    List exerciseItemList = widget.arguments['exerciseItem'];
    exerciseItemListLength = exerciseItemList.length;
    /*List<String> nameList = [
      for (int i = 0; i < exerciseItemList.length; i++)
        "${exerciseItem[i]}"
    ];*/
    return exerciseItemList;
  }

  /*  GIF 輪播 */

  void _showFeedbackDialog() async {
    await showDialog<double>(
      context: context,
      builder: (context) => FeedbackDialog(),
    );
  }

  void startTimer() {
    if (ifStart) {
      ifStart = false;
    } else {
      ifStart = true;
    }

    Timer.periodic(period, (timer) {
      if (totalTime < 1) {
        DurationDB.update(
            {Calendar.toKey(DateTime.now()): "${currentIndex + 1}"});
        _showFeedbackDialog();
        timer.cancel();
        dispose();
        //ifStart = true;
        //Navigator.pushNamed(context, '/exercise');
      } else if (ifStart == false) {
        // TODO: .gif 暫停播放(偏難)
        timer.cancel();
        //_controller.pause();
      } else {
        // Appbar timer
        totalTime--;
        //_controller.play();

        // Video timer
        countDown--;
        if (countDown < 1 && totalTime >= 1) {
          List nameList = _getExerciseItemNameList();

          countDown = 6; // 60s
          if (currentIndex < 2 || currentIndex >= nameList.length - 3) {
            currentIndex++;
            _pageController.animateToPage(currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
            sport = (currentIndex <= 2) ? "暖身：" : "伸展：";
            sport += nameList[currentIndex];
          } else {
            currentIndex++;
            _pageController.animateToPage(currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
            sport = "運動：${nameList[currentIndex]}";

            // 運動 5 秒後休息 1 秒
            Timer(const Duration(seconds: 5), () {
              _pageController.animateToPage(nameList.length + 1,
                  duration: const Duration(milliseconds: 5),
                  curve: Curves.ease);
              sport = "休息：${nameList[currentIndex]}";
            });
          }
          print(
              "currentIndex: $currentIndex ... sport: $sport ... totalTime: $totalTime");
        }
      }
      setState(() {});
      /*print("totalTime: $totalTime");
      print("countDown: $countDown");
      print("currentIndex: $currentIndex");
      print("--------------------");*/
    });
  }

  @override
  void initState() {
    // Create and store the VideoPlayerController.
    //_controller = VideoPlayerController.asset('assets/videos/videoTest.mp4');
    // Initialize the controller and store the Future for later use.
    //_initializeVideoPlayerFuture = _controller.initialize();
    // Use the controller to loop the video.
    //_controller.setLooping(true);

    super.initState();
    totalTime = widget.arguments['exerciseTime']; // initial totalTime
    // initial first exercise's name
    sport = "暖身：${_getExerciseItemNameList()[currentIndex]}";
    _pageController = PageController(initialPage: currentIndex);
    print(
        "currentIndex: $currentIndex ... sport: $sport ... totalTime: $totalTime");
    /*print("totalTime: $totalTime");
    print("countDown: $countDown");
    print("currentIndex: $currentIndex");
    print("--------------------");*/

    ///當前頁面繪製完第一幀後回撥
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startTimer();
    });
  }

  @override
  void dispose() {
    //銷毀 controller
    _pageController.dispose();
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          startTimer();
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    '目前運動已經完成 ${(currentIndex / exerciseItemListLength * 100).round()}% 囉！\n確定要退出，之後再繼續完成嗎？"'),
                actions: [
                  OutlinedButton(
                      child: const Text(
                        "取消",
                        style: TextStyle(
                          color: Color(0xff0d3b66),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        startTimer();
                        Navigator.pop(context, false);
                      }),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfffbb87f),
                      ),
                      onPressed: () {
                        DurationDB.update(
                            {Calendar.toKey(DateTime.now()): "$currentIndex"});
                        Navigator.pop(context, true);
                        //Navigator.pushNamedAndRemoveUntil(
                        //    context, '/', (Route<dynamic> route) => false);
                      },
                      child: const Text(
                        "確定",
                        style: TextStyle(
                          color: Color(0xff0d3b66),
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              );
            },
          );
          return shouldPop!;
        },
        child: Scaffold(
          body: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 10),
                height: 60,
                width: MediaQuery.of(context).size.width,
                color: const Color(0xfffaf0ca),
                child: Text(
                  constructTime(totalTime),
                  //'$seconds',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: Color(0xff0d3b66),
                      fontSize: 32,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      height: 1),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: const BoxDecoration(
                    color: Color(0x193598f5),
                    borderRadius: BorderRadius.all(Radius.circular(13))),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 10),
                height: 60,
                width: MediaQuery.of(context).size.width - 20,
                child: Text(
                  sport,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: Color(0xff0d3b66),
                      fontSize: 32,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      height: 1),
                ),
              ),
              const SizedBox(height: 10),
              /*Container(
            child: Image(
              image: AssetImage('images/testPic.gif'),//video
            ),
          ),*/
              SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: buildVideoBanner(
                    _getVideoList(widget.arguments['exerciseItem'])),
                /*child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the video.
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  );
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),*/
              ),
              Container(
                  padding: const EdgeInsets.only(right: 10),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => startTimer(),
                        icon: Icon(
                          ifStart ? Icons.pause : Icons.play_arrow_rounded,
                          color: const Color(0xff0d3b66),
                        ),
                        label: Text(
                          ifStart ? '暫停' : '繼續',
                          style: const TextStyle(
                              color: Color(0xff0d3b66),
                              fontSize: 24,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffffa493),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }
}

// 運動回饋
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  FeedbackDialogState createState() => FeedbackDialogState();
}

class FeedbackDialogState extends State<FeedbackDialog> {
  double _currentValue1 = 1;
  double _currentValue2 = 1;
  List<int> feedbackData = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('每日運動回饋',
          style: TextStyle(
            backgroundColor: Colors.yellow,
            color: Color(0xff0d3b66),
          )),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.only(top: 1),
          child: const Text(
            '運動是否滿意?',
            textAlign: TextAlign.left,
            style: TextStyle(
                //backgroundColor: Colors.yellow,
                color: Color(0xff0d3b66),
                fontSize: 25,
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                height: 1),
          ),
        ),
        Slider(
          value: _currentValue1,
          min: 1,
          max: 5,
          divisions: 4,
          label: _currentValue1.round().toString(),
          onChanged: (value) {
            setState(() {
              _currentValue1 = value;
            });
          },
        ),
        const Text(
          '1                                    5',
          textAlign: TextAlign.left,
          style: TextStyle(
              //backgroundColor: Colors.yellow,
              color: Color(0xff0d3b66),
              fontSize: 20,
              letterSpacing: 0,
              fontWeight: FontWeight.bold,
              height: 1),
        ),
        Container(
          padding: const EdgeInsets.only(top: 25),
          child: const Text(
            '運動是否疲憊?',
            textAlign: TextAlign.left,
            style: TextStyle(
                //backgroundColor: Colors.yellow,
                color: Color(0xff0d3b66),
                fontSize: 25,
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                height: 1),
          ),
        ),
        Slider(
          value: _currentValue2,
          min: 1,
          max: 5,
          divisions: 4,
          label: _currentValue2.round().toString(),
          onChanged: (value) {
            setState(() {
              _currentValue2 = value;
            });
          },
        ),
        const Text(
          '1                                    5',
          textAlign: TextAlign.left,
          style: TextStyle(
              //backgroundColor: Colors.yellow,
              color: Color(0xff0d3b66),
              fontSize: 20,
              letterSpacing:
                  0 /*percentages not used in flutter. defaulting to zero*/,
              fontWeight: FontWeight.bold,
              height: 1),
        ),
      ]),
      actions: [
        ElevatedButton(
            child: const Text("Submit"),
            onPressed: () async {
              feedbackData.add(_currentValue1.toInt());
              feedbackData.add(_currentValue2.toInt());
              print("FeedbackData: $feedbackData");
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (Route<dynamic> route) => false);
              var type = await PlanDB.getWorkoutType(DateTime.now());
              if (type != null) {
                UserDB.updateByFeedback(type, feedbackData);
              }
              await PlanAlgo.execute();
              MilestoneDB.step();
              //var profile = await UserDB.getPlanVariables(userID);
              // Map<String, dynamic> _likings = {}, _abilities = {};
              // _likings = profile[2];
              // _abilities = profile[3];

              /* if (FeedbackData[0] == 1) {
                UserDB.update(userID, {"strengthAbility": 69});
              }*/
            }),
      ],
    );
  }
}
