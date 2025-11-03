import 'package:flutter/material.dart';
import 'home_screen_new.dart';
import 'search_screen.dart';
import 'trips_screen.dart';
import 'review_screen.dart';
import 'account_screen.dart';
import '../components/custom_bottom_nav.dart';
import '../components/menu_drawer.dart';

class MainScreen extends StatefulWidget {
  final int? initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Use initialTabIndex if provided, otherwise default to 0
    _currentIndex = widget.initialTabIndex ?? 0;
    // Clamp to valid range
    if (_currentIndex < 0 || _currentIndex > 4) {
      _currentIndex = 0;
    }
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab index if it changed (e.g., from menu navigation)
    if (widget.initialTabIndex != null &&
        widget.initialTabIndex != oldWidget.initialTabIndex) {
      final newIndex = widget.initialTabIndex!;
      if (newIndex >= 0 && newIndex <= 4) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    }
  }

  // Create screens list once to preserve state
  late final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const TripsScreen(),
    const ReviewScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
