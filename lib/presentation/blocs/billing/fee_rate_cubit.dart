import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/people.dart';

class FeeRateState extends Equatable {
  const FeeRateState({
    this.rate = AppConstants.defaultServiceFeeRate,
    this.charity = false,
    this.busy = false,
  });

  final double rate;
  final bool charity;
  final bool busy;

  FeeRateState copyWith({double? rate, bool? charity, bool? busy}) {
    return FeeRateState(
      rate: rate ?? this.rate,
      charity: charity ?? this.charity,
      busy: busy ?? this.busy,
    );
  }

  @override
  List<Object?> get props => [rate, charity, busy];
}

/// تنظیم نرخ ۰٫۵٪ تا ۱٪ یا کارمزد صفر خیریه.
class FeeRateCubit extends Cubit<FeeRateState> {
  FeeRateCubit({Fund? fund})
      : super(
          FeeRateState(
            rate: fund?.serviceFeeRate ?? AppConstants.defaultServiceFeeRate,
            charity: fund?.isCharity ?? false,
          ),
        );

  void rateChanged(double value) {
    final clamped = value.clamp(AppConstants.minServiceFeeRate, AppConstants.maxServiceFeeRate);
    emit(state.copyWith(rate: clamped));
  }

  void charityChanged(bool value) => emit(state.copyWith(charity: value));
}
