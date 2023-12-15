import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class DosenTutorialPage extends StatefulWidget {
  const DosenTutorialPage({super.key});

  @override
  State<DosenTutorialPage> createState() => _DosenTutorialPageState();
}

class _DosenTutorialPageState extends State<DosenTutorialPage> {
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
          title: "Create Schedule",
          body:
              "Go to the create schedule page with the \"+\" menu in navigation bar",
          image: _buildImage('tutorial/dosen/dosenStep1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Choose The Times Each Dates",
          body:
              "Create your schedule by choosing the times by each date. The schedule resets every sunday",
          image: _buildImage('tutorial/dosen/dosenStep2.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Check Schedule",
          body:
              "Your schedule are now visible in student and your homepage as tickets. You can delete each tickets if you want to change your mind",
          image: _buildImage('tutorial/dosen/dosenStep3.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Validate or Cancel",
          body:
              "If a student took a ticket, it's also available in your schedule page. You've access to cancel appoinment if you want, but if you not, we are hoping you can validate the student absence",
          image: _buildImage('tutorial/dosen/dosenStep4.jpg'),
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
