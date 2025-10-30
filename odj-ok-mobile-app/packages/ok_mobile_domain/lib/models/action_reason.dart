part of '../ok_mobile_domain.dart';

enum ActionReason {
  damagedLabel(jsonKey: 'Damaged'),
  unreadableLabel(jsonKey: 'Illegible'),
  damagedSeal(jsonKey: 'Damaged'),
  unreadableSeal(jsonKey: 'Illegible'),
  tornBag(jsonKey: 'BagBroken'),
  tornBox(jsonKey: 'BoxBroken'),
  technicalIssue(jsonKey: 'TechnicalIssues'),
  clientResignation(jsonKey: 'ClientResignation'),
  differentIssue(jsonKey: 'Other'),
  lostVoucher(jsonKey: 'VoucherLost'),
  illegibleVoucher(jsonKey: 'VoucherIllegible'),
  differentReason(jsonKey: 'Other'),
  voucherIssuance(jsonKey: 'VoucherIssuance'),
  errorOnFirstPrint(jsonKey: 'PrintError'),
  incorrectlyRejected(jsonKey: 'RejectedByMistake');

  const ActionReason({required this.jsonKey});

  final String jsonKey;

  String get label {
    switch (this) {
      case ActionReason.unreadableLabel:
        return S.current.unreadable_label;
      case ActionReason.damagedLabel:
        return S.current.damaged_label;
      case ActionReason.tornBag:
        return S.current.torn_bag;
      case ActionReason.tornBox:
        return S.current.torn_box;
      case ActionReason.damagedSeal:
        return S.current.damaged_seal;
      case ActionReason.unreadableSeal:
        return S.current.unreadable_seal;
      case ActionReason.clientResignation:
        return S.current.client_resignation;
      case ActionReason.technicalIssue:
        return S.current.technical_issue;
      case ActionReason.differentIssue:
        return S.current.different_issue;
      case ActionReason.lostVoucher:
        return S.current.lost_voucher;
      case ActionReason.illegibleVoucher:
        return S.current.illegible_voucher;
      case ActionReason.differentReason:
        return S.current.different_reason;
      case ActionReason.voucherIssuance:
        return S.current.voucher_issuance;
      case ActionReason.errorOnFirstPrint:
        return S.current.error_on_first_print;
      case ActionReason.incorrectlyRejected:
        return S.current.incorrectly_rejected;
    }
  }
}
