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
      iconName: 'shield',
      title: 'ایجاد صندوق',
      body: 'در کمتر از یک دقیقه صندوق خانوادگی خود را با سهم مشخص و حساب شفاف بسازید.',
    ),
    OnboardingSlide(
      iconName: 'invite',
      title: 'دعوت اعضا',
      body: 'با یک کد کوتاه، اعضای خانواده را اضافه کنید. هر کس فقط اطلاعات خودش را می‌بیند.',
    ),
    OnboardingSlide(
      iconName: 'verify',
      title: 'مدیریت شفاف',
      body: 'پرداخت‌ها فقط با تأیید مدیر ثبت می‌شود. موجودی، وام و معوقات همیشه در دسترس است.',
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
