# Flutter Performance Optimization Guide

## Identified Performance Issues

### 1. Heavy Image Assets
- Large background images (`images/bg.jpg`) used in multiple screens
- Multiple sponsor images loaded in memory simultaneously

### 2. Timer-based State Updates
- Auto-sliding banners with `Timer.periodic` causing frequent rebuilds
- `setState()` called every 3 seconds in Choice.dart

### 3. Memory Management
- Multiple large screens with heavy assets
- Potential memory leaks from timers and async operations

### 4. Firebase Initialization
- Firebase initialization in main() may cause startup delays

## Optimization Recommendations

### 1. Image Optimization
```dart
// Use cached network images or optimize local images
Image.asset(
  'images/bg.jpg',
  fit: BoxFit.cover,
  cacheWidth: MediaQuery.of(context).size.width.toInt(), // Optimize for screen size
  cacheHeight: MediaQuery.of(context).size.height.toInt(),
)
```

### 2. Timer Optimization
```dart
// In Choice.dart, optimize the timer
void _startAutoSlide() {
  _timer = Timer.periodic(const Duration(seconds: 5), (timer) { // Increase to 5 seconds
    if (mounted) {
      setState(() {
        currentIndex = (currentIndex + 1) % sponsors.length;
      });
    }
  });
}
```

### 3. Memory Management
```dart
// Always check mounted before setState
@override
void dispose() {
  _timer.cancel();
  super.dispose();
}
```

### 4. Lazy Loading
- Consider using `AutomaticKeepAliveClientMixin` for screens that don't need constant rebuilding
- Implement pagination for any lists that might grow large

### 5. Build Optimization
```dart
// Use const constructors where possible
const Text(
  'Welcome!',
  style: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
)
```

### 6. Development Performance Tips
1. **Use Profile Mode**: Run with `flutter run --profile` to identify performance bottlenecks
2. **Flutter DevTools**: Use the performance tab to analyze frame rates and memory usage
3. **Hot Restart**: Use instead of full app restart during development
4. **Avoid Debug Mode**: Debug mode is slower, use profile mode for performance testing

### 7. Firebase Optimization
```dart
// Consider lazy initialization if not all screens need Firebase
Future<void> initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: firebaseOptions);
  }
}
```

## Quick Wins to Implement

1. Increase timer interval from 3 to 5 seconds in Choice.dart
2. Add `mounted` checks before all `setState()` calls
3. Optimize image loading with proper cache dimensions
4. Use `const` constructors for static widgets
5. Run in profile mode to identify specific bottlenecks

## Monitoring
- Use Flutter DevTools to monitor:
  - Frame rate (aim for 60fps)
  - Memory usage (watch for leaks)
  - Widget rebuild counts
  - GPU performance
