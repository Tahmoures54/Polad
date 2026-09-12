import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/iso_date_time_converter.dart';
import 'enums.dart';

part 'draw.freezed.dart';
part 'draw.g.dart';

/// دوره قرعه‌کشی صندوق.
///
/// [period] کلید دوره است؛ ترجیحاً شمسی مثل `1404-07`.
/// تا قبل از اجرا [winnerId] و [drawnAt] خالی می‌مانند.
@freezed
abstract class Draw with _$Draw {
  /// سازندهٔ اصلی مدل قرعه.
  const factory Draw({
    /// شناسه سند قرعه‌کشی.
    required String drawId,

    /// صندوق برگزارکننده.
    required String fundId,

    /// شناسه دوره (مثلاً سال-ماه شمسی).
    required String period,

    /// برنده — پس از اجرا پر می‌شود.
    String? winnerId,

    /// زمان انجام قرعه.
    @NullableIsoDateTimeConverter() DateTime? drawnAt,

    /// روش انتخاب برنده.
    required DrawMethod method,
  }) = _Draw;

  /// ساخت مدل از JSON / Map فایراستور.
  factory Draw.fromJson(Map<String, dynamic> json) => _$DrawFromJson(json);
}
