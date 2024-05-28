import 'package:flutter/material.dart';

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({super.key});

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 395.0,
            height: 231.0,
            margin: const EdgeInsets.only(top: 0.0, left: 1.0),
            decoration: BoxDecoration(
              color: const Color(0xFF4C6E4D),
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: VideoPlayerWidget(videoUrl: 'your_video_url'),
          ),
          Container(
            width: 385.0,
            height: 115.5,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(buttonName: 'A', topMargin: 0.0),
                    CustomButton(buttonName: 'B', topMargin: 0.0),
                    CustomButton(buttonName: 'C', topMargin: 0.0),
                    CustomButton(buttonName: 'D', topMargin: 0.0),
                    CustomButton(buttonName: 'E', topMargin: 0.0),
                  ],
                ),
                Container(
                  width: 334.86,
                  height: 29.96,
                  margin: const EdgeInsets.only(top: 10.03),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: const Color(0xFF24201b),
                      width: 1.0,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add button functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF24201b),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Live chat',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 12.0,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: Colors.red, // Change color as needed
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Center(
                            child: Text(
                              '',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    size: 16.0,
                  ),
                ),
              ],
            ),
          ),
      Container(
        color: Colors.white,
        height: 333.0,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chat is disabled',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 7.0),
                Text(
                  'Chat will open once you have answered',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 210.47,
              left: 31.49,
              child: ElevatedButton(
                onPressed: () {
                  // Add your action when the button is pressed
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Container(
                  width: 151.01,
                  height: 35.99,
                  child: Center(
                    child: Text(
                      'Answer Submitted',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),



      ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String buttonName;
  final double topMargin;

  CustomButton({required this.buttonName, required this.topMargin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 61.05,
      height: 42.72,
      margin: EdgeInsets.only(top: topMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Color(0xFF24201b),
      ),
      child: ElevatedButton(
        onPressed: () {
          // Add button functionality here
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          buttonName,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Video Player Placeholder'),
    );
  }
}


