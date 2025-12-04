import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:azas/screens/clock_screen.dart';
import 'package:azas/screens/timer_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/clock',
  routes: [
    GoRoute(
      path: '/clock',
      pageBuilder: (context, state) =>
          _buildFadePage(key: state.pageKey, child: const ClockScreen()),
    ),
    GoRoute(
      path: '/timer',
      pageBuilder: (context, state) =>
          _buildFadePage(key: state.pageKey, child: const TimerScreen()),
    ),
  ],
);

// Fade 전환 (홈 → 로딩)
CustomTransitionPage _buildFadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
