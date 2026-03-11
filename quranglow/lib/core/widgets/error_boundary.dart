import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class GlobalErrorBoundary extends StatefulWidget {
  final Widget child;

  const GlobalErrorBoundary({super.key, required this.child});

  @override
  State<GlobalErrorBoundary> createState() => _GlobalErrorBoundaryState();
}

class _GlobalErrorBoundaryState extends State<GlobalErrorBoundary> {
  bool _hasError = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
  }

  static Widget _defaultErrorBuilder(BuildContext context, Object error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'عذرًا، حدث خطأ غير متوقع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // In a real app, you might want to restart the app or navigate to home
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _defaultErrorBuilder(context, _error!);
    }

    return ErrorWidget.withDetails(
      message: 'UI Error caught by boundary',
      onError: (details) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
        setState(() {
          _hasError = true;
          _error = details.exception;
        });
      },
      child: widget.child,
    );
  }
}

// Extension to wrap a widget with an error boundary
extension ErrorBoundaryExtension on Widget {
  Widget withErrorBoundary() => GlobalErrorBoundary(child: this);
}
