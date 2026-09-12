import 'package:equatable/equatable.dart';

import '../enums.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.phone,
    required this.displayName,
    required this.createdAt,
    this.avatarUrl,
    this.fundIds = const [],
    this.activeFundId,
    this.fcmToken,
  });

  final String id;
  final String phone;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> fundIds;
  final String? activeFundId;
  final String? fcmToken;

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    List<String>? fundIds,
    String? activeFundId,
    String? fcmToken,
  }) {
    return UserProfile(
      id: id,
      phone: phone,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      fundIds: fundIds ?? this.fundIds,
      activeFundId: activeFundId ?? this.activeFundId,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'phone': phone,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
    'fundIds': fundIds,
    'activeFundId': activeFundId,
    'fcmToken': fcmToken,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'] as String,
    phone: map['phone'] as String,
    displayName: map['displayName'] as String? ?? '',
    avatarUrl: map['avatarUrl'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    fundIds: (map['fundIds'] as List?)?.cast<String>() ?? const [],
    activeFundId: map['activeFundId'] as String?,
    fcmToken: map['fcmToken'] as String?,
  );

  @override
  List<Object?> get props => [id, phone, displayName, activeFundId, fundIds];
}

class Fund extends Equatable {
  const Fund({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.adminId,
    required this.shareAmount,
    required this.paymentPeriodDays,
    required this.serviceFeeRate,
    required this.loanAdminFeeRate,
    required this.createdAt,
    required this.tier,
    this.charterText,
    this.bankIban,
    this.bankAccount,
    this.bankName = 'ملت',
    this.isCharity = false,
    this.memberCount = 0,
    this.balance = 0,
  });

  final String id;
  final String name;
  final String inviteCode;
  final String adminId;
  final int shareAmount;
  final int paymentPeriodDays;
  final double serviceFeeRate;
  final double loanAdminFeeRate;
  final DateTime createdAt;
  final SubscriptionTier tier;
  final String? charterText;
  final String? bankIban;
  final String? bankAccount;
  final String bankName;
  final bool isCharity;
  final int memberCount;
  final int balance;

  int get memberLimit => tier == SubscriptionTier.premium ? 100000 : 10;
  bool get isPremium => tier == SubscriptionTier.premium;

  Fund copyWith({
    String? name,
    int? shareAmount,
    int? paymentPeriodDays,
    double? serviceFeeRate,
    String? charterText,
    String? bankIban,
    String? bankAccount,
    bool? isCharity,
    SubscriptionTier? tier,
    int? memberCount,
    int? balance,
  }) {
    return Fund(
      id: id,
      name: name ?? this.name,
      inviteCode: inviteCode,
      adminId: adminId,
      shareAmount: shareAmount ?? this.shareAmount,
      paymentPeriodDays: paymentPeriodDays ?? this.paymentPeriodDays,
      serviceFeeRate: serviceFeeRate ?? this.serviceFeeRate,
      loanAdminFeeRate: loanAdminFeeRate,
      createdAt: createdAt,
      tier: tier ?? this.tier,
      charterText: charterText ?? this.charterText,
      bankIban: bankIban ?? this.bankIban,
      bankAccount: bankAccount ?? this.bankAccount,
      bankName: bankName,
      isCharity: isCharity ?? this.isCharity,
      memberCount: memberCount ?? this.memberCount,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'inviteCode': inviteCode,
    'adminId': adminId,
    'shareAmount': shareAmount,
    'paymentPeriodDays': paymentPeriodDays,
    'serviceFeeRate': serviceFeeRate,
    'loanAdminFeeRate': loanAdminFeeRate,
    'createdAt': createdAt.toIso8601String(),
    'tier': tier.name,
    'charterText': charterText,
    'bankIban': bankIban,
    'bankAccount': bankAccount,
    'bankName': bankName,
    'isCharity': isCharity,
    'memberCount': memberCount,
    'balance': balance,
  };

  factory Fund.fromMap(Map<String, dynamic> map) => Fund(
    id: map['id'] as String,
    name: map['name'] as String,
    inviteCode: map['inviteCode'] as String,
    adminId: map['adminId'] as String,
    shareAmount: map['shareAmount'] as int,
    paymentPeriodDays: map['paymentPeriodDays'] as int,
    serviceFeeRate: (map['serviceFeeRate'] as num).toDouble(),
    loanAdminFeeRate: (map['loanAdminFeeRate'] as num).toDouble(),
    createdAt: DateTime.parse(map['createdAt'] as String),
    tier: SubscriptionTier.values.byName(map['tier'] as String? ?? 'free'),
    charterText: map['charterText'] as String?,
    bankIban: map['bankIban'] as String?,
    bankAccount: map['bankAccount'] as String?,
    bankName: map['bankName'] as String? ?? 'ملت',
    isCharity: map['isCharity'] as bool? ?? false,
    memberCount: map['memberCount'] as int? ?? 0,
    balance: map['balance'] as int? ?? 0,
  );

  @override
  List<Object?> get props => [id, name, inviteCode, balance, memberCount, tier];
}

class FundMember extends Equatable {
  const FundMember({
    required this.userId,
    required this.fundId,
    required this.role,
    required this.displayName,
    required this.phone,
    required this.joinedAt,
    this.status = MemberStatus.active,
    this.shareBalance = 0,
    this.debt = 0,
    this.credit = 0,
  });

  final String userId;
  final String fundId;
  final UserRole role;
  final String displayName;
  final String phone;
  final DateTime joinedAt;
  final MemberStatus status;
  final int shareBalance;
  final int debt;
  final int credit;

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'fundId': fundId,
    'role': role.name,
    'displayName': displayName,
    'phone': phone,
    'joinedAt': joinedAt.toIso8601String(),
    'status': status.name,
    'shareBalance': shareBalance,
    'debt': debt,
    'credit': credit,
  };

  factory FundMember.fromMap(Map<String, dynamic> map) => FundMember(
    userId: map['userId'] as String,
    fundId: map['fundId'] as String,
    role: UserRole.values.byName(map['role'] as String),
    displayName: map['displayName'] as String,
    phone: map['phone'] as String,
    joinedAt: DateTime.parse(map['joinedAt'] as String),
    status: MemberStatus.values.byName(map['status'] as String? ?? 'active'),
    shareBalance: map['shareBalance'] as int? ?? 0,
    debt: map['debt'] as int? ?? 0,
    credit: map['credit'] as int? ?? 0,
  );

  FundMember copyWith({
    UserRole? role,
    MemberStatus? status,
    int? shareBalance,
    int? debt,
    int? credit,
    String? displayName,
  }) {
    return FundMember(
      userId: userId,
      fundId: fundId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      phone: phone,
      joinedAt: joinedAt,
      status: status ?? this.status,
      shareBalance: shareBalance ?? this.shareBalance,
      debt: debt ?? this.debt,
      credit: credit ?? this.credit,
    );
  }

  @override
  List<Object?> get props => [userId, fundId, role, shareBalance, debt, credit, status];
}
