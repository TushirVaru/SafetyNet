// import 'package:SafetyNet/screens/sign_in.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
//
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> {
//
//   bool isLastPage = false;
//   final PageController pageViewController = PageController();
//
//   @override
//   void dispose() {
//     pageViewController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.only(bottom: 80),
//         child: Expanded(
//           child: PageView(
//             controller: pageViewController,
//             onPageChanged: (index) {
//               setState(() {
//                 isLastPage = index == 2;
//               });
//             },
//             children: [
//               _buildPage(
//                 title: 'Welcome',
//                 description: 'Discover awesome features of the app.',
//                 imagePath: 'assets/Welcome.jpg',
//               ),
//               _buildPage(
//                 title: 'Explore',
//                 description: 'Explore various tools and functionalities.',
//                 imagePath: 'assets/Explore.jpg',
//               ),
//               _buildPage(
//                 title: 'Get Started',
//                 description: 'Let\'s start using the app now.',
//                 imagePath: 'assets/GetStarted.jpg',
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomSheet: isLastPage
//           ? Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: SizedBox(
//                 height: 80,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () async{
//
//                         //setting isFirstTime false
//                         SharedPreferences prefs = await SharedPreferences.getInstance();
//                         prefs.setBool("isFirstTime", false);
//
//                         Navigator.of(context).pushReplacement(
//                           MaterialPageRoute(builder: (context) => const SignIn()),
//                         );
//                       },
//                       child: const Text("Get Started"),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           : Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: SizedBox(
//               height: 80,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Skip Button
//                   TextButton(
//                     onPressed: () {
//                       pageViewController.jumpToPage(2); // Jump to the last page
//                     },
//                     child: const Text('Skip'),
//                   ),
//
//               // Page Indicator
//               Center(
//                 child: SmoothPageIndicator(
//                   controller: pageViewController,
//                   count: 3,
//                   onDotClicked: (index) => pageViewController.animateToPage(
//                     index,
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeIn,
//                   ),
//                 ),
//               ),
//
//               // Next Button
//               TextButton(
//                 onPressed: () {
//                   if (pageViewController.page != 2) {
//                     pageViewController.nextPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeIn,
//                     );
//                   }
//                 },
//                 child: const Text('Next'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPage({required String title, required String description, required String imagePath}) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Image.asset(imagePath),
//         const SizedBox(height: 20),
//         Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 10),
//         Text(description, style: const TextStyle(fontSize: 16)),
//       ],
//     );
//   }
// }
