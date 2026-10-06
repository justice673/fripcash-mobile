import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Defers [notifyListeners] when called during a frame build.
mixin SafeNotify on ChangeNotifier {
  void safeNotifyListeners() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    final duringBuild = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;
    if (duringBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }
}

/// Runs [action] after the current frame (safe from [State.initState]).
void runAfterFrame(VoidCallback action) {
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
}
