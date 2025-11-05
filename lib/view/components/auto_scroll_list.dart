import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/place_card.dart';
import '../../data/models/place_model.dart';

class AutoScrollList extends StatefulWidget {
  final List<Place> places;
  final double height;
  final double itemWidth;
  final double itemHeight;
  final Function(Place)? onTap;
  final Duration scrollDuration;
  final Duration pauseDuration;
  final bool reverseDirection;

  const AutoScrollList({
    super.key,
    required this.places,
    this.height = 200,
    this.itemWidth = 160,
    this.itemHeight = 200,
    this.onTap,
    this.scrollDuration = const Duration(milliseconds: 2000),
    this.pauseDuration = const Duration(seconds: 3),
    this.reverseDirection = false,
  });

  @override
  State<AutoScrollList> createState() => _AutoScrollListState();
}

class _AutoScrollListState extends State<AutoScrollList> {
  late ScrollController _scrollController;
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  bool _isPaused = false;
  bool _isHovered = false;
  bool _isUserScrolling = false;
  bool _isAutoScrolling = false;
  int _currentIndex = 0;
  bool _isInitialized = false;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Listen to scroll changes to detect manual scrolling
    _scrollController.addListener(_onScrollChanged);

    // Initialize scroll position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.places.isNotEmpty) {
        _initializeScrollPosition();
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    if (!_isInitialized) return;
    
    final currentPosition = _scrollController.position.pixels;
    
    // If position changed and we're not auto-scrolling, user is manually scrolling
    if (!_isAutoScrolling && (_lastScrollPosition != currentPosition)) {
      if (!_isUserScrolling) {
        // User started scrolling manually
        _isUserScrolling = true;
        _pauseScroll();
      }
      
      // Reset resume timer whenever user scrolls
      _resumeTimer?.cancel();
      _resumeTimer = Timer(const Duration(milliseconds: 1500), () {
        // User stopped scrolling, resume auto-scroll
        if (mounted && _isUserScrolling) {
          _isUserScrolling = false;
          _updateCurrentIndexFromScrollPosition();
          _resumeScroll();
        }
      });
    }
    
    _lastScrollPosition = currentPosition;
  }

  void _updateCurrentIndexFromScrollPosition() {
    if (!mounted || !_isInitialized) return;
    
    final itemWidth = widget.itemWidth + 12;
    final listLength = widget.places.length;
    final currentPosition = _scrollController.position.pixels;
    
    // Calculate current index from scroll position
    final calculatedIndex = (currentPosition / itemWidth).round();
    
    // Normalize to middle copy range [listLength ... 2*listLength-1]
    if (calculatedIndex < listLength) {
      _currentIndex = calculatedIndex + listLength;
    } else if (calculatedIndex >= 2 * listLength) {
      _currentIndex = calculatedIndex - listLength;
    } else {
      _currentIndex = calculatedIndex;
    }
    
    // Ensure we're in the valid range
    if (_currentIndex < listLength) {
      _currentIndex += listLength;
      _scrollController.jumpTo(_currentIndex * itemWidth);
    } else if (_currentIndex >= 2 * listLength) {
      _currentIndex -= listLength;
      _scrollController.jumpTo(_currentIndex * itemWidth);
    }
  }

  void _initializeScrollPosition() {
    final itemWidth = widget.itemWidth + 12;
    final listLength = widget.places.length;

    if (widget.reverseDirection) {
      // For reverse: start at END of middle copy (rightmost visible position)
      // Middle copy is at indices [listLength ... 2*listLength-1]
      _currentIndex = (2 * listLength) - 1; // Last item of middle copy
    } else {
      // For normal: start at START of middle copy
      _currentIndex = listLength; // First item of middle copy
    }

    final initialPosition = _currentIndex * itemWidth;
    _scrollController.jumpTo(initialPosition);
    _lastScrollPosition = initialPosition;
    _isInitialized = true;
  }

  void _startAutoScroll() {
    if (widget.places.length <= 1) return;

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.pauseDuration, (timer) {
      if (!_isPaused && !_isHovered && !_isUserScrolling && mounted) {
        _moveToNextCard();
      }
    });
  }

  void _moveToNextCard() {
    if (!mounted || widget.places.isEmpty || !_isInitialized || _isUserScrolling) return;

    final itemWidth = widget.itemWidth + 12;
    final listLength = widget.places.length;

    // Move to next card
    if (widget.reverseDirection) {
      _currentIndex--; // Move leftward
    } else {
      _currentIndex++; // Move rightward
    }

    final targetPosition = _currentIndex * itemWidth;

    // Mark that we're auto-scrolling
    _isAutoScrolling = true;
    _lastScrollPosition = _scrollController.position.pixels;

    // Animate to target
    _scrollController
        .animateTo(
          targetPosition,
          duration: widget.scrollDuration,
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (!mounted) return;
          
          _isAutoScrolling = false;
          _lastScrollPosition = _scrollController.position.pixels;

          // Check boundaries and jump if needed (seamless loop)
          if (widget.reverseDirection) {
            // If we've scrolled too far left (before first copy), jump to equivalent position in middle copy
            if (_currentIndex < listLength) {
              _currentIndex += listLength;
              final jumpPosition = _currentIndex * itemWidth;
              _scrollController.jumpTo(jumpPosition);
              _lastScrollPosition = jumpPosition;
            }
          } else {
            // If we've scrolled too far right (past middle copy), jump to equivalent position in middle copy
            if (_currentIndex >= 2 * listLength) {
              _currentIndex -= listLength;
              final jumpPosition = _currentIndex * itemWidth;
              _scrollController.jumpTo(jumpPosition);
              _lastScrollPosition = jumpPosition;
            }
          }
        });
  }

  void _pauseScroll() {
    setState(() {
      _isPaused = true;
    });
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
  }

  void _resumeScroll() {
    if (_isUserScrolling) return; // Don't resume if user is still scrolling
    
    setState(() {
      _isPaused = false;
    });
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No places available')),
      );
    }

    // Create infinite list by duplicating the places
    final infinitePlaces = [
      ...widget.places,
      ...widget.places,
      ...widget.places,
    ];

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _pauseScroll();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _resumeScroll();
      },
      child: GestureDetector(
        onTapDown: (_) => _pauseScroll(),
        onTapUp: (_) => _resumeScroll(),
        onTapCancel: () => _resumeScroll(),
        child: SizedBox(
          height: widget.height,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: infinitePlaces.length,
            itemBuilder: (context, index) {
              final place = infinitePlaces[index];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PlaceCard(
                  place: place,
                  width: widget.itemWidth,
                  height: widget.itemHeight,
                  onTap: () {
                    _pauseScroll();
                    widget.onTap?.call(place);
                    // Resume after a delay
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        _resumeScroll();
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
