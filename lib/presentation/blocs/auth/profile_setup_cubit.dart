import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/validators.dart';
import '../../../data/local/cache_store.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';

class ProfileSetupState extends Equatable {
  const ProfileSetupState({
    this.name = '',
    this.role = UserRole.admin,
    this.isFirstUser = true,
    this.submitted = false,
    this.busy = false,
    this.error,
    this.saved = false,
  });

  final String name;
  final UserRole role;
  final bool isFirstUser;
  final bool submitted;
  final bool busy;
  final String? error;
  final bool saved;

  String? get nameError {
    if (!submitted && name.isEmpty) return null;
    return Validators.personName(name);
  }

  bool get canSave => Validators.personName(name) == null && !busy;

  ProfileSetupState copyWith({
    String? name,
    UserRole? role,
    bool? isFirstUser,
    bool? submitted,
    bool? busy,
    String? error,
    bool? saved,
    bool clearError = false,
  }) {
    return ProfileSetupState(
      name: name ?? this.name,
      role: role ?? this.role,
      isFirstUser: isFirstUser ?? this.isFirstUser,
      submitted: submitted ?? this.submitted,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [name, role, isFirstUser, submitted, busy, error, saved];
}

/// نام نمایشی و نقش اولیه؛ اولین کاربر صندوق مدیر است.
class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  ProfileSetupCubit({
    AuthRepository? auth,
    this._cache,
  })  : _auth = auth ?? sl<AuthRepository>(),
        super(const ProfileSetupState()) {
    final user = _auth.currentUser;
    final first = user == null || user.fundIds.isEmpty;
    final existing = user?.displayName.trim() ?? '';
    final placeholder = existing == 'کاربر جدید' || existing == 'کاربر پولاد';
    emit(ProfileSetupState(
      name: placeholder ? '' : existing,
      role: first ? UserRole.admin : UserRole.member,
      isFirstUser: first,
    ));
  }

  final AuthRepository _auth;
  final CacheStore? _cache;

  void nameChanged(String value) => emit(state.copyWith(name: value, saved: false, clearError: true));

  void roleChanged(UserRole role) => emit(state.copyWith(role: role, saved: false));

  Future<void> save() async {
    emit(state.copyWith(submitted: true, clearError: true));
    if (!state.canSave) {
      emit(state.copyWith(error: state.nameError));
      return;
    }
    emit(state.copyWith(busy: true));
    final res = await _auth.updateProfile(displayName: state.name.trim());
    await res.when(
      ok: (_) async {
        final store = _cache ?? (sl.isRegistered<CacheStore>() ? sl<CacheStore>() : null);
        await store?.setIntendedRole(state.role.name);
        emit(state.copyWith(busy: false, saved: true));
      },
      err: (m) async => emit(state.copyWith(busy: false, error: m)),
    );
  }
}
