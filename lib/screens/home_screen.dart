import 'package:flutter/material.dart';
import 'home_tab_screen.dart';
import 'master_tab_screen.dart';
import 'ai_tab_screen.dart';
import 'me_tab_screen.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/type_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _typeIndex = 0;

  List<Widget> get _screens => [
    HomeTabScreen(typeIndex: _typeIndex),
    const MasterTabScreen(),
    const AiTabScreen(),
    const MeTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          if (_currentIndex == 0)
            Positioned(
              left: 20,
              right: 20,
              top: statusBarHeight + 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Switch to AI tab
                  });
                },
                child: SizedBox(
                  height: 146,
                  child: Image.asset(
                    'assets/pebbo_home_trend.webp',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          if (_currentIndex == 0)
            Positioned(
              left: 20,
              top: statusBarHeight + 16 + 146 + 20,
              child: TypeSelector(
                selectedIndex: _typeIndex,
                onChanged: (index) {
                  setState(() {
                    _typeIndex = index;
                  });
                },
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: CustomTabBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

