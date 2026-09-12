class AppConstants {
  static const minServiceFeeRate = 0.005;
  static const maxServiceFeeRate = 0.01;
  static const defaultServiceFeeRate = 0.005;
  static const loanAdminFeeRate = 0.02;
  static const freeMemberLimit = 10;
  static const freeFundLimit = 1;
  static const otpLength = 6;
  static const demoOtp = '123456';
  static const demoAdminPhone = '09120000000';
  static const demoMemberPhone = '09121111111';
  static const inviteCodeLength = 6;
  static const cacheTtl = Duration(hours: 12);
  static const reminderHoursBeforeDue = 24;
  static const defaultShareToman = 5000000;
  static const defaultPeriodDays = 30;
  static const hiveBoxCache = 'polad_cache';
  static const prefsOnboarding = 'onboarding_done';
  static const prefsActiveFund = 'active_fund_id';
  static const prefsSessionUser = 'session_user_id';
  static const prefsIntendedRole = 'intended_role';
  static const otpResendSeconds = 60;
}

class CollectionPaths {
  static const users = 'users';
  static const funds = 'funds';
  static const transactions = 'transactions';
  static const loans = 'loans';
  static const installments = 'installments';
  static const draws = 'draws';
  static const invoices = 'service_invoices';
  static const fees = 'fees';
  static const payments = 'payment_orders';
  static const notifications = 'notifications';
  static const receiptsPrefix = 'receipts';

  static String fundMembers(String fundId) => 'funds/$fundId/members';
  static String fundInvites(String fundId) => 'funds/$fundId/invites';
}
