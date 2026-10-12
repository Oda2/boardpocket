import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Navigation helpers that tolerate an empty navigation stack.
extension SafePop on BuildContext {
  /// Pops the current route, falling back to [fallback] when there is nothing
  /// left to pop.
  ///
  /// The bottom tab bar navigates with `go()`, which *replaces* the stack, so a
  /// screen reached that way has no history. Since go_router 18, popping the
  /// last page throws `currentConfiguration.isNotEmpty` instead of being a
  /// no-op, which used to crash the back button on every tabbed screen.
  void popOrGo({String fallback = '/'}) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}
