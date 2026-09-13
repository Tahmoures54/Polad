import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../data/local/cache_store.dart';

/// اسلایدهای معرفی صندوق خانوادگی پولاد.
class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.body,
    required this.iconName,
  });

  final String title;
  final String body;

  /// کلید آیکن برای لایهٔ نمایش (از وابستگی Material در کیوبیت پرهیز می‌شود).
  final String iconName;
}

class OnboardingState extends Equatable {
  const OnboardingState({this.index = 0});

  final int index;

  static const slides = <OnboardingSlide>[
    OnboardingSlide(
      iconName: 'simple',
      title: 'ساده برای همه',
      body: 'سه کار بیشتر نیست: سهم بگذار، وام بخواه، مدیر تأیید کند. شارژ ساختمان و دفتر حسابداری اینجا نیست.',
    ),
    OnboardingSlide(
      iconName: 'fast',
      title: 'کار مدیر کم',
      body: 'صف تأیید همان کار است. پیامک و بانک فقط پیشنهاد می‌دهند؛ شما در چند لمس تصمیم می‌گیرید.',
    ),
    OnboardingSlide(
      iconName: 'clear',
      title: 'حساب برای همه روشن',
      body: 'عضو هم موجودی و وضعیت پرداخت را می‌بیند. از واریز کسی بابت نرم‌افزار کم نمی‌شود.',
    ),
  ];

  int get pageCount => slides.length;
  bool get isLast => index >= pageCount - 1;
  OnboardingSlide get current => slides[index.clamp(0, pageCount - 1)];

  @override
  List<Object?> get props => [index];
}

/// وضعیت اسلاید معرفی و اتمام آن.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({this._cache}) : super(const OnboardingState());

  final CacheStore? _cache;

  void goTo(int index) {
    if (index < 0 || index >= OnboardingState.slides.length) return;
    emit(OnboardingState(index: index));
  }

  void next() {
    if (state.isLast) return;
    emit(OnboardingState(index: state.index + 1));
  }

  /// ثبت «معرفی دیده شد» تا دفعهٔ بعد مستقیم به ورود برود.
  Future<void> complete() async {
    final store = _cache ?? (sl.isRegistered<CacheStore>() ? sl<CacheStore>() : null);
    await store?.setOnboardingDone();
  }
}
