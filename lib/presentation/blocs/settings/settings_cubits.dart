import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/locator.dart';
import '../../../data/local/cache_store.dart';

/// تم روشن / تاریک / سیستم — نسخهٔ اول زبان فقط فارسی است.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({CacheStore? cache})
      : _cache = cache ?? sl<CacheStore>(),
        super(_parse((cache ?? sl<CacheStore>()).themeMode));

  final CacheStore _cache;

  static ThemeMode _parse(String raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setMode(ThemeMode mode) async {
    final wire = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _cache.setThemeMode(wire);
    emit(mode);
  }
}

class NotificationPrefsCubit extends Cubit<NotificationPrefs> {
  NotificationPrefsCubit({CacheStore? cache})
      : _cache = cache ?? sl<CacheStore>(),
        super(
          NotificationPrefs(
            installment: (cache ?? sl<CacheStore>()).notif(AppConstants.prefsNotifInstallment),
            draw: (cache ?? sl<CacheStore>()).notif(AppConstants.prefsNotifDraw),
            fee: (cache ?? sl<CacheStore>()).notif(AppConstants.prefsNotifFee),
          ),
        );

  final CacheStore _cache;

  Future<void> setInstallment(bool v) async {
    await _cache.setNotif(AppConstants.prefsNotifInstallment, v);
    emit(state.copyWith(installment: v));
  }

  Future<void> setDraw(bool v) async {
    await _cache.setNotif(AppConstants.prefsNotifDraw, v);
    emit(state.copyWith(draw: v));
  }

  Future<void> setFee(bool v) async {
    await _cache.setNotif(AppConstants.prefsNotifFee, v);
    emit(state.copyWith(fee: v));
  }
}

class NotificationPrefs {
  const NotificationPrefs({required this.installment, required this.draw, required this.fee});
  final bool installment;
  final bool draw;
  final bool fee;

  NotificationPrefs copyWith({bool? installment, bool? draw, bool? fee}) {
    return NotificationPrefs(
      installment: installment ?? this.installment,
      draw: draw ?? this.draw,
      fee: fee ?? this.fee,
    );
  }
}
