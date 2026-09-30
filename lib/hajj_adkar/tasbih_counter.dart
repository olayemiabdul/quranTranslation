import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../quran_ayah/reader_theme.dart';

/// A counter for a dhikr said a set number of times.
///
/// This is the thing an adhkar page exists for and the old page did not
/// have: nowhere to keep count while saying something thirty-three times.
/// The whole row is the tap target, with a haptic tick on each count and a
/// stronger one when the number is reached, so it can be used without
/// looking at the screen.
class TasbihCounter extends StatelessWidget {
  final int target;
  final int value;
  final ValueChanged<int> onChanged;

  const TasbihCounter({
    super.key,
    required this.target,
    required this.value,
    required this.onChanged,
  });

  bool get _done => value >= target;

  void _tap() {
    if (_done) {
      onChanged(0); // tapping a finished counter starts it again
      HapticFeedback.selectionClick();
      return;
    }
    final next = value + 1;
    onChanged(next);
    next >= target
        ? HapticFeedback.mediumImpact()
        : HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);
    final progress = target == 0 ? 0.0 : (value / target).clamp(0.0, 1.0);

    return Material(
      color: _done
          ? ReaderTheme.gold.withValues(alpha: t.dark ? 0.18 : 0.22)
          : t.headerBand,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
      child: InkWell(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
        onTap: _tap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: t.divider,
                      color: _done ? ReaderTheme.gold : ReaderTheme.green,
                    ),
                    if (_done)
                      const Icon(Icons.check,
                          size: 16, color: ReaderTheme.gold)
                    else
                      Text('$value',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: t.ink)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _done
                      ? 'Done · tap to start again'
                      : target > 1
                          ? 'Tap to count · $value of $target'
                          : 'Tap when said',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _done ? ReaderTheme.green : t.ink),
                ),
              ),
              if (value > 0 && !_done)
                IconButton(
                  tooltip: 'Undo',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.undo, size: 18, color: t.inkSoft),
                  onPressed: () => onChanged(value - 1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
