import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.pop(context);
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('style/img/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0, fontFamily: 'Quicksand');

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, fontFamily: 'Quicksand'),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.only(top: 100),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 3000,
      infiniteAutoScroll: true,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.only(
            top: 16,
            right: 16,
          ),
          child: _buildImage('LogoInformateach.png', 100),
        )),
      ),

      pages: [
        PageViewModel(
          title: "Choose Your Lecturer",
          body:
              "At your home page, you can choose a lecturer to create an appoinment ticket with",
          image: _buildImage('tutorial/mhs/step1.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Pick A Time",
          body:
              "Choose yout create your appoinment ticket by picking the available day and time. We also hope that you can fill the appoinment purpose field.",
          image: _buildImage('tutorial/mhs/step2.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Check And Confirm Ticket",
          body:
              "Check your ticket once more and confirm it if you already sure of your ticket",
          image: _buildImage('tutorial/mhs/step3.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Check Ongoing Ticket",
          body:
              "Go to the Ticket page by selecting the 'Ticket' menu at bottom navigation bar.",
          image: _buildImage('tutorial/mhs/step4.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Cancel Ticket",
          body:
              "Your ongoing ticket will be showed here and you can cancel it. But remember, a student only can cancel a ticket 3 times and 1 hour before the appoinment ticket schedule.",
          image: _buildImage('tutorial/mhs/step5.jpg'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      skip: const Text('Skip',
          style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
              color: Colors.white)),
      next: const Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      done: const Text('Done',
          style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
              color: Colors.white)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.all(5.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.white,
        // activeColor: Colors.white,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color(0xFF27374D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28.0)),
        ),
      ),
    );
  }
}
