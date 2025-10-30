// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Return deposit packages`
  String get return_deposing_packages {
    return Intl.message(
      'Return deposit packages',
      name: 'return_deposing_packages',
      desc: '',
      args: [],
    );
  }

  /// `Manage bags`
  String get manage_bags {
    return Intl.message('Manage bags', name: 'manage_bags', desc: '', args: []);
  }

  /// `Manage collection units`
  String get manage_boxes {
    return Intl.message(
      'Manage collection units',
      name: 'manage_boxes',
      desc: '',
      args: [],
    );
  }

  /// `Order pickup`
  String get order_pickup {
    return Intl.message(
      'Order pickup',
      name: 'order_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Hand over to driver`
  String get handing_over_driver {
    return Intl.message(
      'Hand over to driver',
      name: 'handing_over_driver',
      desc: '',
      args: [],
    );
  }

  /// `Manuals`
  String get manuals {
    return Intl.message('Manuals', name: 'manuals', desc: '', args: []);
  }

  /// `Administration`
  String get admin {
    return Intl.message('Administration', name: 'admin', desc: '', args: []);
  }

  /// `Log out`
  String get logout {
    return Intl.message('Log out', name: 'logout', desc: '', args: []);
  }

  /// `Return`
  String get return_text {
    return Intl.message('Return', name: 'return_text', desc: '', args: []);
  }

  /// `Return summary`
  String get return_summary {
    return Intl.message(
      'Return summary',
      name: 'return_summary',
      desc: '',
      args: [],
    );
  }

  /// `Open new bag`
  String get open_new_bag {
    return Intl.message(
      'Open new bag',
      name: 'open_new_bag',
      desc: '',
      args: [],
    );
  }

  /// `Open new plastic bag`
  String get open_new_bag_plastic {
    return Intl.message(
      'Open new plastic bag',
      name: 'open_new_bag_plastic',
      desc: '',
      args: [],
    );
  }

  /// `Open new can bag`
  String get open_new_bag_CAN {
    return Intl.message(
      'Open new can bag',
      name: 'open_new_bag_CAN',
      desc: '',
      args: [],
    );
  }

  /// `Choose open bag`
  String get choose_open_bag {
    return Intl.message(
      'Choose open bag',
      name: 'choose_open_bag',
      desc: '',
      args: [],
    );
  }

  /// `Choose open plastic bag`
  String get choose_open_bag_plastic {
    return Intl.message(
      'Choose open plastic bag',
      name: 'choose_open_bag_plastic',
      desc: '',
      args: [],
    );
  }

  /// `Choose open can bag`
  String get choose_open_bag_CAN {
    return Intl.message(
      'Choose open can bag',
      name: 'choose_open_bag_CAN',
      desc: '',
      args: [],
    );
  }

  /// `Closed bags`
  String get closed_bags {
    return Intl.message('Closed bags', name: 'closed_bags', desc: '', args: []);
  }

  /// `Closed returns`
  String get closed_returns {
    return Intl.message(
      'Closed returns',
      name: 'closed_returns',
      desc: '',
      args: [],
    );
  }

  /// `Closed returns archive`
  String get closed_returns_archive {
    return Intl.message(
      'Closed returns archive',
      name: 'closed_returns_archive',
      desc: '',
      args: [],
    );
  }

  /// `Selected day: {day}`
  String selected_day(Object day) {
    return Intl.message(
      'Selected day: $day',
      name: 'selected_day',
      desc: '',
      args: [day],
    );
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Closed bags list`
  String get closed_bags_list {
    return Intl.message(
      'Closed bags list',
      name: 'closed_bags_list',
      desc: '',
      args: [],
    );
  }

  /// `Filter:`
  String get filter {
    return Intl.message('Filter:', name: 'filter', desc: '', args: []);
  }

  /// `Plastic`
  String get plastic {
    return Intl.message('Plastic', name: 'plastic', desc: '', args: []);
  }

  /// `Can`
  String get can {
    return Intl.message('Can', name: 'can', desc: '', args: []);
  }

  /// `Pieces`
  String get pieces {
    return Intl.message('Pieces', name: 'pieces', desc: '', args: []);
  }

  /// `Change bag`
  String get change_bag {
    return Intl.message('Change bag', name: 'change_bag', desc: '', args: []);
  }

  /// `Pickup`
  String get pickup {
    return Intl.message('Pickup', name: 'pickup', desc: '', args: []);
  }

  /// `Sent bags`
  String get sent_bags {
    return Intl.message('Sent bags', name: 'sent_bags', desc: '', args: []);
  }

  /// `Bag`
  String get bag {
    return Intl.message('Bag', name: 'bag', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `No packages in open return.`
  String get no_packeges_in_return {
    return Intl.message(
      'No packages in open return.',
      name: 'no_packeges_in_return',
      desc: '',
      args: [],
    );
  }

  /// `Reject return`
  String get reject_return {
    return Intl.message(
      'Reject return',
      name: 'reject_return',
      desc: '',
      args: [],
    );
  }

  /// `I confirm package return completion`
  String get i_confirm_finish {
    return Intl.message(
      'I confirm package return completion',
      name: 'i_confirm_finish',
      desc: '',
      args: [],
    );
  }

  /// `Return cannot be edited after this stage`
  String get next_stage_edit_impossible {
    return Intl.message(
      'Return cannot be edited after this stage',
      name: 'next_stage_edit_impossible',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `I confirm voucher print for return`
  String get confirm_voucher_print {
    return Intl.message(
      'I confirm voucher print for return',
      name: 'confirm_voucher_print',
      desc: '',
      args: [],
    );
  }

  /// `Voucher has been printed`
  String get voucher_printed_for_client {
    return Intl.message(
      'Voucher has been printed',
      name: 'voucher_printed_for_client',
      desc: '',
      args: [],
    );
  }

  /// `No printer found. Go to Settings and add device`
  String get no_printer_configured {
    return Intl.message(
      'No printer found. Go to Settings and add device',
      name: 'no_printer_configured',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get closed {
    return Intl.message('Closed', name: 'closed', desc: '', args: []);
  }

  /// `Print voucher for client`
  String get print_voucher_for_client {
    return Intl.message(
      'Print voucher for client',
      name: 'print_voucher_for_client',
      desc: '',
      args: [],
    );
  }

  /// `Print voucher`
  String get print_voucher {
    return Intl.message(
      'Print voucher',
      name: 'print_voucher',
      desc: '',
      args: [],
    );
  }

  /// `Package return`
  String get packages_return {
    return Intl.message(
      'Package return',
      name: 'packages_return',
      desc: '',
      args: [],
    );
  }

  /// `Return sum PLN`
  String get pln_return_sum {
    return Intl.message(
      'Return sum PLN',
      name: 'pln_return_sum',
      desc: '',
      args: [],
    );
  }

  /// `Camera access denied`
  String get camera_permission_denied {
    return Intl.message(
      'Camera access denied',
      name: 'camera_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Scan new bag code`
  String get scan_new_bag {
    return Intl.message(
      'Scan new bag code',
      name: 'scan_new_bag',
      desc: '',
      args: [],
    );
  }

  /// `Enter bag number`
  String get enter_bag_number {
    return Intl.message(
      'Enter bag number',
      name: 'enter_bag_number',
      desc: '',
      args: [],
    );
  }

  /// `or enter bag number`
  String get or_enter_bag_number {
    return Intl.message(
      'or enter bag number',
      name: 'or_enter_bag_number',
      desc: '',
      args: [],
    );
  }

  /// `New bag`
  String get new_bag {
    return Intl.message('New bag', name: 'new_bag', desc: '', args: []);
  }

  /// `opened correctly`
  String get properly_opened {
    return Intl.message(
      'opened correctly',
      name: 'properly_opened',
      desc: '',
      args: [],
    );
  }

  /// `Selected bag`
  String get chosen_bag {
    return Intl.message('Selected bag', name: 'chosen_bag', desc: '', args: []);
  }

  /// `Finish return`
  String get finish_return {
    return Intl.message(
      'Finish return',
      name: 'finish_return',
      desc: '',
      args: [],
    );
  }

  /// `Scan package EAN`
  String get scan_package_ean {
    return Intl.message(
      'Scan package EAN',
      name: 'scan_package_ean',
      desc: '',
      args: [],
    );
  }

  /// `or enter EAN number`
  String get or_enter_ean {
    return Intl.message(
      'or enter EAN number',
      name: 'or_enter_ean',
      desc: '',
      args: [],
    );
  }

  /// `Scanned item is not a package`
  String get wrong_package_type {
    return Intl.message(
      'Scanned item is not a package',
      name: 'wrong_package_type',
      desc: '',
      args: [],
    );
  }

  /// `Unknown EAN code`
  String get unknown_ean_code {
    return Intl.message(
      'Unknown EAN code',
      name: 'unknown_ean_code',
      desc: '',
      args: [],
    );
  }

  /// `Open bags list`
  String get open_bags_list {
    return Intl.message(
      'Open bags list',
      name: 'open_bags_list',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to system`
  String get welcome_to_system {
    return Intl.message(
      'Welcome to system',
      name: 'welcome_to_system',
      desc: '',
      args: [],
    );
  }

  /// `OK Deposit Operator`
  String get ok_name {
    return Intl.message(
      'OK Deposit Operator',
      name: 'ok_name',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get log_in {
    return Intl.message('Log in', name: 'log_in', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Wrong login or password.\nPlease log in again.`
  String get invalid_credentials_info {
    return Intl.message(
      'Wrong login or password.\nPlease log in again.',
      name: 'invalid_credentials_info',
      desc: '',
      args: [],
    );
  }

  /// `EMPTY`
  String get empty {
    return Intl.message('EMPTY', name: 'empty', desc: '', args: []);
  }

  /// `Closed returns list`
  String get closed_returns_list {
    return Intl.message(
      'Closed returns list',
      name: 'closed_returns_list',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String get correct {
    return Intl.message('Correct', name: 'correct', desc: '', args: []);
  }

  /// `Canceled`
  String get canceled {
    return Intl.message('Canceled', name: 'canceled', desc: '', args: []);
  }

  /// `is not a deposit package`
  String get is_not_deposit_package {
    return Intl.message(
      'is not a deposit package',
      name: 'is_not_deposit_package',
      desc: '',
      args: [],
    );
  }

  /// `Bag management`
  String get bags_management {
    return Intl.message(
      'Bag management',
      name: 'bags_management',
      desc: '',
      args: [],
    );
  }

  /// `Close bag`
  String get close_bag {
    return Intl.message('Close bag', name: 'close_bag', desc: '', args: []);
  }

  /// `Change label`
  String get change_label {
    return Intl.message(
      'Change label',
      name: 'change_label',
      desc: '',
      args: [],
    );
  }

  /// `Change seal`
  String get change_seal {
    return Intl.message('Change seal', name: 'change_seal', desc: '', args: []);
  }

  /// `Add bags to collection unit`
  String get add_bags_to_box {
    return Intl.message(
      'Add bags to collection unit',
      name: 'add_bags_to_box',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `Returns archive`
  String get returns_archive {
    return Intl.message(
      'Returns archive',
      name: 'returns_archive',
      desc: '',
      args: [],
    );
  }

  /// `Bag has been closed.`
  String get bag_was_closed {
    return Intl.message(
      'Bag has been closed.',
      name: 'bag_was_closed',
      desc: '',
      args: [],
    );
  }

  /// `Scan bag code or select from list`
  String get scan_or_pick_bag_number {
    return Intl.message(
      'Scan bag code or select from list',
      name: 'scan_or_pick_bag_number',
      desc: '',
      args: [],
    );
  }

  /// `Closed bag`
  String get closed_bag {
    return Intl.message('Closed bag', name: 'closed_bag', desc: '', args: []);
  }

  /// `Add seal`
  String get add_seal {
    return Intl.message('Add seal', name: 'add_seal', desc: '', args: []);
  }

  /// `Add to collection unit`
  String get add_to_box {
    return Intl.message(
      'Add to collection unit',
      name: 'add_to_box',
      desc: '',
      args: [],
    );
  }

  /// `No connection - try again!`
  String get no_internet {
    return Intl.message(
      'No connection - try again!',
      name: 'no_internet',
      desc: '',
      args: [],
    );
  }

  /// `Bag with this number already exists - change label.`
  String get duplicated_label_error {
    return Intl.message(
      'Bag with this number already exists - change label.',
      name: 'duplicated_label_error',
      desc: '',
      args: [],
    );
  }

  /// `New bag {id} opened correctly.`
  String new_bag_properly_opened(Object id) {
    return Intl.message(
      'New bag $id opened correctly.',
      name: 'new_bag_properly_opened',
      desc: '',
      args: [id],
    );
  }

  /// `Selected {type} bag {id}.`
  String bag_was_chosen_with_type(Object id, Object type) {
    return Intl.message(
      'Selected $type bag $id.',
      name: 'bag_was_chosen_with_type',
      desc: '',
      args: [id, type],
    );
  }

  /// `Selected bag {id}.`
  String bag_was_chosen(Object id) {
    return Intl.message(
      'Selected bag $id.',
      name: 'bag_was_chosen',
      desc: '',
      args: [id],
    );
  }

  /// `Return has been closed. Print voucher.`
  String get return_closed_print_voucher {
    return Intl.message(
      'Return has been closed. Print voucher.',
      name: 'return_closed_print_voucher',
      desc: '',
      args: [],
    );
  }

  /// `No packages in open bag`
  String get no_packages_in_open_bag {
    return Intl.message(
      'No packages in open bag',
      name: 'no_packages_in_open_bag',
      desc: '',
      args: [],
    );
  }

  /// `Open bags have been fetched`
  String get open_bags_has_been_fetched {
    return Intl.message(
      'Open bags have been fetched',
      name: 'open_bags_has_been_fetched',
      desc: '',
      args: [],
    );
  }

  /// `Configure printer`
  String get configure_printer {
    return Intl.message(
      'Configure printer',
      name: 'configure_printer',
      desc: '',
      args: [],
    );
  }

  /// `Add printer to start deposit package return`
  String get add_printer_to_start_return {
    return Intl.message(
      'Add printer to start deposit package return',
      name: 'add_printer_to_start_return',
      desc: '',
      args: [],
    );
  }

  /// `Add printer to start pickup`
  String get add_printer_to_start_pickup {
    return Intl.message(
      'Add printer to start pickup',
      name: 'add_printer_to_start_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Printer configuration`
  String get printer_config {
    return Intl.message(
      'Printer configuration',
      name: 'printer_config',
      desc: '',
      args: [],
    );
  }

  /// `No printer selected`
  String get no_chosen_printer {
    return Intl.message(
      'No printer selected',
      name: 'no_chosen_printer',
      desc: '',
      args: [],
    );
  }

  /// `Selected printer`
  String get chosen_printer {
    return Intl.message(
      'Selected printer',
      name: 'chosen_printer',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Scan new printer code`
  String get scan_new_printer_code {
    return Intl.message(
      'Scan new printer code',
      name: 'scan_new_printer_code',
      desc: '',
      args: [],
    );
  }

  /// `or enter number`
  String get or_enter_number {
    return Intl.message(
      'or enter number',
      name: 'or_enter_number',
      desc: '',
      args: [],
    );
  }

  /// `or search by label`
  String get or_search_by_label {
    return Intl.message(
      'or search by label',
      name: 'or_search_by_label',
      desc: '',
      args: [],
    );
  }

  /// `Selected printer {mac_address}`
  String printer_was_chosen(Object mac_address) {
    return Intl.message(
      'Selected printer $mac_address',
      name: 'printer_was_chosen',
      desc: '',
      args: [mac_address],
    );
  }

  /// `Removed last added printer`
  String get removed_last_printer {
    return Intl.message(
      'Removed last added printer',
      name: 'removed_last_printer',
      desc: '',
      args: [],
    );
  }

  /// `Wrong bag number`
  String get incorrect_bag_number {
    return Intl.message(
      'Wrong bag number',
      name: 'incorrect_bag_number',
      desc: '',
      args: [],
    );
  }

  /// `Bag is already closed.`
  String get bag_already_closed {
    return Intl.message(
      'Bag is already closed.',
      name: 'bag_already_closed',
      desc: '',
      args: [],
    );
  }

  /// `No open bags`
  String get no_open_bags {
    return Intl.message(
      'No open bags',
      name: 'no_open_bags',
      desc: '',
      args: [],
    );
  }

  /// `Open new collection unit`
  String get open_new_box {
    return Intl.message(
      'Open new collection unit',
      name: 'open_new_box',
      desc: '',
      args: [],
    );
  }

  /// `Choose open collection unit`
  String get choose_open_box {
    return Intl.message(
      'Choose open collection unit',
      name: 'choose_open_box',
      desc: '',
      args: [],
    );
  }

  /// `Close collection units`
  String get close_boxes {
    return Intl.message(
      'Close collection units',
      name: 'close_boxes',
      desc: '',
      args: [],
    );
  }

  /// `Change collection unit label`
  String get change_box_label {
    return Intl.message(
      'Change collection unit label',
      name: 'change_box_label',
      desc: '',
      args: [],
    );
  }

  /// `Submit collection units for pickup`
  String get submit_boxes_for_pickup {
    return Intl.message(
      'Submit collection units for pickup',
      name: 'submit_boxes_for_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Submitted for pickup`
  String get submitted_for_pickup {
    return Intl.message(
      'Submitted for pickup',
      name: 'submitted_for_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Mon`
  String get monday_short {
    return Intl.message('Mon', name: 'monday_short', desc: '', args: []);
  }

  /// `Tue`
  String get tuesday_short {
    return Intl.message('Tue', name: 'tuesday_short', desc: '', args: []);
  }

  /// `Wed`
  String get wednesday_short {
    return Intl.message('Wed', name: 'wednesday_short', desc: '', args: []);
  }

  /// `Thu`
  String get thursday_short {
    return Intl.message('Thu', name: 'thursday_short', desc: '', args: []);
  }

  /// `Fri`
  String get friday_short {
    return Intl.message('Fri', name: 'friday_short', desc: '', args: []);
  }

  /// `Sat`
  String get saturday_short {
    return Intl.message('Sat', name: 'saturday_short', desc: '', args: []);
  }

  /// `Sun`
  String get sunday_short {
    return Intl.message('Sun', name: 'sunday_short', desc: '', args: []);
  }

  /// `Scan new collection unit code`
  String get scan_new_box {
    return Intl.message(
      'Scan new collection unit code',
      name: 'scan_new_box',
      desc: '',
      args: [],
    );
  }

  /// `or enter collection unit number`
  String get or_enter_box_number {
    return Intl.message(
      'or enter collection unit number',
      name: 'or_enter_box_number',
      desc: '',
      args: [],
    );
  }

  /// `New collection unit opened correctly`
  String get new_box_opened_correctly {
    return Intl.message(
      'New collection unit opened correctly',
      name: 'new_box_opened_correctly',
      desc: '',
      args: [],
    );
  }

  /// `Collection unit`
  String get box {
    return Intl.message('Collection unit', name: 'box', desc: '', args: []);
  }

  /// `Scan collection unit code or select from list`
  String get scan_box_label_or_pick_from_list {
    return Intl.message(
      'Scan collection unit code or select from list',
      name: 'scan_box_label_or_pick_from_list',
      desc: '',
      args: [],
    );
  }

  /// `Collection unit opened correctly`
  String get box_correctly_opened {
    return Intl.message(
      'Collection unit opened correctly',
      name: 'box_correctly_opened',
      desc: '',
      args: [],
    );
  }

  /// `Collection unit not found`
  String get box_not_found {
    return Intl.message(
      'Collection unit not found',
      name: 'box_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Bag label has been changed`
  String get label_has_been_changed {
    return Intl.message(
      'Bag label has been changed',
      name: 'label_has_been_changed',
      desc: '',
      args: [],
    );
  }

  /// `Damaged label`
  String get damaged_label {
    return Intl.message(
      'Damaged label',
      name: 'damaged_label',
      desc: '',
      args: [],
    );
  }

  /// `Unreadable label`
  String get unreadable_label {
    return Intl.message(
      'Unreadable label',
      name: 'unreadable_label',
      desc: '',
      args: [],
    );
  }

  /// `Torn bag`
  String get torn_bag {
    return Intl.message('Torn bag', name: 'torn_bag', desc: '', args: []);
  }

  /// `Torn collection unit`
  String get torn_box {
    return Intl.message(
      'Torn collection unit',
      name: 'torn_box',
      desc: '',
      args: [],
    );
  }

  /// `Choose reason for label change`
  String get choose_reason_for_label_change {
    return Intl.message(
      'Choose reason for label change',
      name: 'choose_reason_for_label_change',
      desc: '',
      args: [],
    );
  }

  /// `Bag has been sealed.`
  String get seal_added_successfully {
    return Intl.message(
      'Bag has been sealed.',
      name: 'seal_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Close collection unit`
  String get close_box {
    return Intl.message(
      'Close collection unit',
      name: 'close_box',
      desc: '',
      args: [],
    );
  }

  /// `Collection unit summary`
  String get box_summary {
    return Intl.message(
      'Collection unit summary',
      name: 'box_summary',
      desc: '',
      args: [],
    );
  }

  /// `Scan bag code`
  String get scan_bag_code {
    return Intl.message(
      'Scan bag code',
      name: 'scan_bag_code',
      desc: '',
      args: [],
    );
  }

  /// `Bag has been added to collection unit`
  String get bag_was_added_to_box {
    return Intl.message(
      'Bag has been added to collection unit',
      name: 'bag_was_added_to_box',
      desc: '',
      args: [],
    );
  }

  /// `Bag cannot be added to collection unit because it is not closed.`
  String get bag_not_closed {
    return Intl.message(
      'Bag cannot be added to collection unit because it is not closed.',
      name: 'bag_not_closed',
      desc: '',
      args: [],
    );
  }

  /// `Bag with given code not found`
  String get bag_not_found {
    return Intl.message(
      'Bag with given code not found',
      name: 'bag_not_found',
      desc: '',
      args: [],
    );
  }

  /// `This bag is not assigned to your collection point`
  String get bag_not_assigned_to_collection_point {
    return Intl.message(
      'This bag is not assigned to your collection point',
      name: 'bag_not_assigned_to_collection_point',
      desc: '',
      args: [],
    );
  }

  /// `Bag has been removed from collection unit`
  String get bag_was_removed_from_box {
    return Intl.message(
      'Bag has been removed from collection unit',
      name: 'bag_was_removed_from_box',
      desc: '',
      args: [],
    );
  }

  /// `Scan seal code`
  String get scan_seal {
    return Intl.message(
      'Scan seal code',
      name: 'scan_seal',
      desc: '',
      args: [],
    );
  }

  /// `or enter seal number`
  String get or_enter_seal_number {
    return Intl.message(
      'or enter seal number',
      name: 'or_enter_seal_number',
      desc: '',
      args: [],
    );
  }

  /// `Added seal`
  String get added_seal {
    return Intl.message('Added seal', name: 'added_seal', desc: '', args: []);
  }

  /// `Unreadable seal`
  String get unreadable_seal {
    return Intl.message(
      'Unreadable seal',
      name: 'unreadable_seal',
      desc: '',
      args: [],
    );
  }

  /// `Damaged seal`
  String get damaged_seal {
    return Intl.message(
      'Damaged seal',
      name: 'damaged_seal',
      desc: '',
      args: [],
    );
  }

  /// `Seal has been changed successfully.`
  String get seal_changed_succesfully {
    return Intl.message(
      'Seal has been changed successfully.',
      name: 'seal_changed_succesfully',
      desc: '',
      args: [],
    );
  }

  /// `Choose reason for seal change:`
  String get choose_reason_for_seal_change {
    return Intl.message(
      'Choose reason for seal change:',
      name: 'choose_reason_for_seal_change',
      desc: '',
      args: [],
    );
  }

  /// `This collection unit is not assigned to your collection point`
  String get box_not_assigned_to_collection_point {
    return Intl.message(
      'This collection unit is not assigned to your collection point',
      name: 'box_not_assigned_to_collection_point',
      desc: '',
      args: [],
    );
  }

  /// `Collection unit has already been closed`
  String get box_already_closed {
    return Intl.message(
      'Collection unit has already been closed',
      name: 'box_already_closed',
      desc: '',
      args: [],
    );
  }

  /// `Collection unit has been closed`
  String get box_was_closed {
    return Intl.message(
      'Collection unit has been closed',
      name: 'box_was_closed',
      desc: '',
      args: [],
    );
  }

  /// `All collection units have been closed`
  String get all_boxes_closed {
    return Intl.message(
      'All collection units have been closed',
      name: 'all_boxes_closed',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to confirm closing`
  String get do_you_really_want_to_close {
    return Intl.message(
      'Do you really want to confirm closing',
      name: 'do_you_really_want_to_close',
      desc: '',
      args: [],
    );
  }

  /// `all collection units?`
  String get of_all_boxes {
    return Intl.message(
      'all collection units?',
      name: 'of_all_boxes',
      desc: '',
      args: [],
    );
  }

  /// `collection unit`
  String get of_a_box {
    return Intl.message(
      'collection unit',
      name: 'of_a_box',
      desc: '',
      args: [],
    );
  }

  /// `Declare for pickup`
  String get declare_for_pickup {
    return Intl.message(
      'Declare for pickup',
      name: 'declare_for_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get select_all {
    return Intl.message('Select all', name: 'select_all', desc: '', args: []);
  }

  /// `No closed bags`
  String get no_closed_bags {
    return Intl.message(
      'No closed bags',
      name: 'no_closed_bags',
      desc: '',
      args: [],
    );
  }

  /// `Selected bags`
  String get selected_bags {
    return Intl.message(
      'Selected bags',
      name: 'selected_bags',
      desc: '',
      args: [],
    );
  }

  /// `No collection units to display`
  String get no_boxes_to_display {
    return Intl.message(
      'No collection units to display',
      name: 'no_boxes_to_display',
      desc: '',
      args: [],
    );
  }

  /// `Summary`
  String get summary {
    return Intl.message('Summary', name: 'summary', desc: '', args: []);
  }

  /// `No bags were selected`
  String get no_bags_were_selected {
    return Intl.message(
      'No bags were selected',
      name: 'no_bags_were_selected',
      desc: '',
      args: [],
    );
  }

  /// `Bags have been added to collection unit`
  String get all_bags_added_to_box {
    return Intl.message(
      'Bags have been added to collection unit',
      name: 'all_bags_added_to_box',
      desc: '',
      args: [],
    );
  }

  /// `Session expired, please log in again`
  String get session_expired {
    return Intl.message(
      'Session expired, please log in again',
      name: 'session_expired',
      desc: '',
      args: [],
    );
  }

  /// `No returns for today`
  String get no_returns_today {
    return Intl.message(
      'No returns for today',
      name: 'no_returns_today',
      desc: '',
      args: [],
    );
  }

  /// `This bag is already assigned to a collection unit`
  String get bag_already_added_to_box {
    return Intl.message(
      'This bag is already assigned to a collection unit',
      name: 'bag_already_added_to_box',
      desc: '',
      args: [],
    );
  }

  /// `No bags to display`
  String get no_bags_to_display {
    return Intl.message(
      'No bags to display',
      name: 'no_bags_to_display',
      desc: '',
      args: [],
    );
  }

  /// `Seal with this number already exists`
  String get seal_already_exists {
    return Intl.message(
      'Seal with this number already exists',
      name: 'seal_already_exists',
      desc: '',
      args: [],
    );
  }

  /// `Collection point ID cannot be empty`
  String get collection_point_id_empty {
    return Intl.message(
      'Collection point ID cannot be empty',
      name: 'collection_point_id_empty',
      desc: '',
      args: [],
    );
  }

  /// `Collection point with given ID does not exist`
  String get collection_point_not_exist {
    return Intl.message(
      'Collection point with given ID does not exist',
      name: 'collection_point_not_exist',
      desc: '',
      args: [],
    );
  }

  /// `Seal number cannot be empty`
  String get seal_empty {
    return Intl.message(
      'Seal number cannot be empty',
      name: 'seal_empty',
      desc: '',
      args: [],
    );
  }

  /// `Bag is open`
  String get bag_is_open {
    return Intl.message('Bag is open', name: 'bag_is_open', desc: '', args: []);
  }

  /// `Invalid seal/label change reason`
  String get reason_invalid {
    return Intl.message(
      'Invalid seal/label change reason',
      name: 'reason_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Label number cannot be empty`
  String get label_empty {
    return Intl.message(
      'Label number cannot be empty',
      name: 'label_empty',
      desc: '',
      args: [],
    );
  }

  /// `Bag type not found`
  String get type_not_found {
    return Intl.message(
      'Bag type not found',
      name: 'type_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Invalid bag type`
  String get type_invalid {
    return Intl.message(
      'Invalid bag type',
      name: 'type_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Bag number cannot be empty`
  String get bag_empty {
    return Intl.message(
      'Bag number cannot be empty',
      name: 'bag_empty',
      desc: '',
      args: [],
    );
  }

  /// `Collection unit ID list cannot be empty`
  String get box_ids_empty {
    return Intl.message(
      'Collection unit ID list cannot be empty',
      name: 'box_ids_empty',
      desc: '',
      args: [],
    );
  }

  /// `Collection unit number cannot be empty`
  String get box_empty {
    return Intl.message(
      'Collection unit number cannot be empty',
      name: 'box_empty',
      desc: '',
      args: [],
    );
  }

  /// `Invalid event type`
  String get event_type_invalid {
    return Intl.message(
      'Invalid event type',
      name: 'event_type_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Comment cannot be empty`
  String get comment_empty {
    return Intl.message(
      'Comment cannot be empty',
      name: 'comment_empty',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `For sealed bags, both label and seal must be replaced.`
  String get change_seal_after_label_change {
    return Intl.message(
      'For sealed bags, both label and seal must be replaced.',
      name: 'change_seal_after_label_change',
      desc: '',
      args: [],
    );
  }

  /// `Scan seal code or select from list`
  String get scan_seal_or_pick_from_list {
    return Intl.message(
      'Scan seal code or select from list',
      name: 'scan_seal_or_pick_from_list',
      desc: '',
      args: [],
    );
  }

  /// `Wrong seal number.`
  String get incorrect_seal_number {
    return Intl.message(
      'Wrong seal number.',
      name: 'incorrect_seal_number',
      desc: '',
      args: [],
    );
  }

  /// `Scan bag seal code`
  String get scan_bag_seal_code {
    return Intl.message(
      'Scan bag seal code',
      name: 'scan_bag_seal_code',
      desc: '',
      args: [],
    );
  }

  /// `I confirm`
  String get i_confirm {
    return Intl.message('I confirm', name: 'i_confirm', desc: '', args: []);
  }

  /// `Plastic / Can`
  String get mix {
    return Intl.message('Plastic / Can', name: 'mix', desc: '', args: []);
  }

  /// `Bag selected`
  String get bag_chosen {
    return Intl.message('Bag selected', name: 'bag_chosen', desc: '', args: []);
  }

  /// `No open bags of this type`
  String get no_open_bags_of_this_type {
    return Intl.message(
      'No open bags of this type',
      name: 'no_open_bags_of_this_type',
      desc: '',
      args: [],
    );
  }

  /// `Choose reason to cancel voucher print:`
  String get reason_for_voucher_print_cancelation {
    return Intl.message(
      'Choose reason to cancel voucher print:',
      name: 'reason_for_voucher_print_cancelation',
      desc: '',
      args: [],
    );
  }

  /// `Client cancellation`
  String get client_resignation {
    return Intl.message(
      'Client cancellation',
      name: 'client_resignation',
      desc: '',
      args: [],
    );
  }

  /// `Technical issue`
  String get technical_issue {
    return Intl.message(
      'Technical issue',
      name: 'technical_issue',
      desc: '',
      args: [],
    );
  }

  /// `Other issue`
  String get different_issue {
    return Intl.message(
      'Other issue',
      name: 'different_issue',
      desc: '',
      args: [],
    );
  }

  /// `Cancel voucher print`
  String get cancel_voucher_print {
    return Intl.message(
      'Cancel voucher print',
      name: 'cancel_voucher_print',
      desc: '',
      args: [],
    );
  }

  /// `Lost voucher`
  String get lost_voucher {
    return Intl.message(
      'Lost voucher',
      name: 'lost_voucher',
      desc: '',
      args: [],
    );
  }

  /// `Illegible voucher`
  String get illegible_voucher {
    return Intl.message(
      'Illegible voucher',
      name: 'illegible_voucher',
      desc: '',
      args: [],
    );
  }

  /// `Other reason`
  String get different_reason {
    return Intl.message(
      'Other reason',
      name: 'different_reason',
      desc: '',
      args: [],
    );
  }

  /// `Choose voucher reprint reason:`
  String get choose_voucher_reprint_reason {
    return Intl.message(
      'Choose voucher reprint reason:',
      name: 'choose_voucher_reprint_reason',
      desc: '',
      args: [],
    );
  }

  /// `Voucher has been printed`
  String get reprint_voucher_confirmation {
    return Intl.message(
      'Voucher has been printed',
      name: 'reprint_voucher_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Close and seal bag`
  String get close_and_seal {
    return Intl.message(
      'Close and seal bag',
      name: 'close_and_seal',
      desc: '',
      args: [],
    );
  }

  /// `Scan new seal code`
  String get scan_new_seal_code {
    return Intl.message(
      'Scan new seal code',
      name: 'scan_new_seal_code',
      desc: '',
      args: [],
    );
  }

  /// `Before confirming, check that codes are correctly assigned to label and seal numbers.`
  String get make_sure_codes_are_correct {
    return Intl.message(
      'Before confirming, check that codes are correctly assigned to label and seal numbers.',
      name: 'make_sure_codes_are_correct',
      desc: '',
      args: [],
    );
  }

  /// `Label number`
  String get label_number {
    return Intl.message(
      'Label number',
      name: 'label_number',
      desc: '',
      args: [],
    );
  }

  /// `Seal number`
  String get seal_number {
    return Intl.message('Seal number', name: 'seal_number', desc: '', args: []);
  }

  /// `Seal code scanned.`
  String get seal_scan_success {
    return Intl.message(
      'Seal code scanned.',
      name: 'seal_scan_success',
      desc: '',
      args: [],
    );
  }

  /// `Bag label scanned.`
  String get label_scan_success {
    return Intl.message(
      'Bag label scanned.',
      name: 'label_scan_success',
      desc: '',
      args: [],
    );
  }

  /// `Choose voucher print reason:`
  String get choose_voucher_print_reason {
    return Intl.message(
      'Choose voucher print reason:',
      name: 'choose_voucher_print_reason',
      desc: '',
      args: [],
    );
  }

  /// `Voucher issuance`
  String get voucher_issuance {
    return Intl.message(
      'Voucher issuance',
      name: 'voucher_issuance',
      desc: '',
      args: [],
    );
  }

  /// `Error on first print`
  String get error_on_first_print {
    return Intl.message(
      'Error on first print',
      name: 'error_on_first_print',
      desc: '',
      args: [],
    );
  }

  /// `Incorrectly rejected`
  String get incorrectly_rejected {
    return Intl.message(
      'Incorrectly rejected',
      name: 'incorrectly_rejected',
      desc: '',
      args: [],
    );
  }

  /// `Damaged bag`
  String get damaged_bag {
    return Intl.message('Damaged bag', name: 'damaged_bag', desc: '', args: []);
  }

  /// `Bag label and seal changed`
  String get label_and_seal_changed {
    return Intl.message(
      'Bag label and seal changed',
      name: 'label_and_seal_changed',
      desc: '',
      args: [],
    );
  }

  /// `Pickups`
  String get pickups {
    return Intl.message('Pickups', name: 'pickups', desc: '', args: []);
  }

  /// `Pickups overview`
  String get pickups_overview {
    return Intl.message(
      'Pickups overview',
      name: 'pickups_overview',
      desc: '',
      args: [],
    );
  }

  /// `Pickup summary`
  String get pickup_summary {
    return Intl.message(
      'Pickup summary',
      name: 'pickup_summary',
      desc: '',
      args: [],
    );
  }

  /// `Scan bag seal code \nand add bag to pickup`
  String get scan_seal_and_add_bag_to_pickup {
    return Intl.message(
      'Scan bag seal code \nand add bag to pickup',
      name: 'scan_seal_and_add_bag_to_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Last added`
  String get last_added {
    return Intl.message('Last added', name: 'last_added', desc: '', args: []);
  }

  /// `Confirm pickup`
  String get confirm_pickup {
    return Intl.message(
      'Confirm pickup',
      name: 'confirm_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Confirm and print document`
  String get confirm_and_print_document {
    return Intl.message(
      'Confirm and print document',
      name: 'confirm_and_print_document',
      desc: '',
      args: [],
    );
  }

  /// `Package receival`
  String get package_receival {
    return Intl.message(
      'Package receival',
      name: 'package_receival',
      desc: '',
      args: [],
    );
  }

  /// `Planned receivals`
  String get planned_receival {
    return Intl.message(
      'Planned receivals',
      name: 'planned_receival',
      desc: '',
      args: [],
    );
  }

  /// `Receival tally`
  String get receival_tally {
    return Intl.message(
      'Receival tally',
      name: 'receival_tally',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to use this application.`
  String get no_access_contact_admin {
    return Intl.message(
      'You do not have permission to use this application.',
      name: 'no_access_contact_admin',
      desc: '',
      args: [],
    );
  }

  /// `I confirm driver pickup of declared packages.`
  String get i_confirm_pickup {
    return Intl.message(
      'I confirm driver pickup of declared packages.',
      name: 'i_confirm_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Driver pickup confirmed`
  String get pickup_confirmed {
    return Intl.message(
      'Driver pickup confirmed',
      name: 'pickup_confirmed',
      desc: '',
      args: [],
    );
  }

  /// `Driver pickup confirmed.\nPrint error occurred. Try again by going to pickup details`
  String get pickup_confirmed_with_print_error {
    return Intl.message(
      'Driver pickup confirmed.\nPrint error occurred. Try again by going to pickup details',
      name: 'pickup_confirmed_with_print_error',
      desc: '',
      args: [],
    );
  }

  /// `Server error. Please try again later.`
  String get server_error {
    return Intl.message(
      'Server error. Please try again later.',
      name: 'server_error',
      desc: '',
      args: [],
    );
  }

  /// `Item with given ID not found`
  String get item_not_found {
    return Intl.message(
      'Item with given ID not found',
      name: 'item_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Item with given ID is not assigned to your collection point`
  String get item_incorrect_collection_point {
    return Intl.message(
      'Item with given ID is not assigned to your collection point',
      name: 'item_incorrect_collection_point',
      desc: '',
      args: [],
    );
  }

  /// `Item with given ID has not been closed`
  String get item_not_closed {
    return Intl.message(
      'Item with given ID has not been closed',
      name: 'item_not_closed',
      desc: '',
      args: [],
    );
  }

  /// `Item is assigned to another pickup`
  String get item_already_has_status {
    return Intl.message(
      'Item is assigned to another pickup',
      name: 'item_already_has_status',
      desc: '',
      args: [],
    );
  }

  /// `Items list cannot be empty`
  String get items_empty {
    return Intl.message(
      'Items list cannot be empty',
      name: 'items_empty',
      desc: '',
      args: [],
    );
  }

  /// `Receival summary`
  String get receival_summary {
    return Intl.message(
      'Receival summary',
      name: 'receival_summary',
      desc: '',
      args: [],
    );
  }

  /// `Scan bag seal code \nand add bag to receival`
  String get scan_seal_and_add_bag_to_receival {
    return Intl.message(
      'Scan bag seal code \nand add bag to receival',
      name: 'scan_seal_and_add_bag_to_receival',
      desc: '',
      args: [],
    );
  }

  /// `Confirm receival`
  String get confirm_receival {
    return Intl.message(
      'Confirm receival',
      name: 'confirm_receival',
      desc: '',
      args: [],
    );
  }

  /// `Last received`
  String get last_received {
    return Intl.message(
      'Last received',
      name: 'last_received',
      desc: '',
      args: [],
    );
  }

  /// `Released to driver`
  String get released {
    return Intl.message(
      'Released to driver',
      name: 'released',
      desc: '',
      args: [],
    );
  }

  /// `Partially received`
  String get partially_received {
    return Intl.message(
      'Partially received',
      name: 'partially_received',
      desc: '',
      args: [],
    );
  }

  /// `Received in CC`
  String get received_in_cc {
    return Intl.message(
      'Received in CC',
      name: 'received_in_cc',
      desc: '',
      args: [],
    );
  }

  /// `No pickups`
  String get no_pickups {
    return Intl.message('No pickups', name: 'no_pickups', desc: '', args: []);
  }

  /// `No receivals`
  String get no_receivals {
    return Intl.message(
      'No receivals',
      name: 'no_receivals',
      desc: '',
      args: [],
    );
  }

  /// `Plastic bottles (pieces):`
  String get pet_quantity {
    return Intl.message(
      'Plastic bottles (pieces):',
      name: 'pet_quantity',
      desc: '',
      args: [],
    );
  }

  /// `Cans (pieces):`
  String get can_quantity {
    return Intl.message(
      'Cans (pieces):',
      name: 'can_quantity',
      desc: '',
      args: [],
    );
  }

  /// `Total:`
  String get total_quantity {
    return Intl.message('Total:', name: 'total_quantity', desc: '', args: []);
  }

  /// `Invalid`
  String get invalid {
    return Intl.message('Invalid', name: 'invalid', desc: '', args: []);
  }

  /// `Packages on the way`
  String get packages_on_the_way {
    return Intl.message(
      'Packages on the way',
      name: 'packages_on_the_way',
      desc: '',
      args: [],
    );
  }

  /// `Collected packages`
  String get collected_packages {
    return Intl.message(
      'Collected packages',
      name: 'collected_packages',
      desc: '',
      args: [],
    );
  }

  /// `Contact Administrator to fix this issue.`
  String get contact_admin {
    return Intl.message(
      'Contact Administrator to fix this issue.',
      name: 'contact_admin',
      desc: '',
      args: [],
    );
  }

  /// `Wrong device assignment to counting center.`
  String get wrong_device_to_cc {
    return Intl.message(
      'Wrong device assignment to counting center.',
      name: 'wrong_device_to_cc',
      desc: '',
      args: [],
    );
  }

  /// `Wrong user assignment to counting center.`
  String get wrong_user_to_cc {
    return Intl.message(
      'Wrong user assignment to counting center.',
      name: 'wrong_user_to_cc',
      desc: '',
      args: [],
    );
  }

  /// `Wrong device assignment to retail chain.`
  String get wrong_device_to_retail_chain {
    return Intl.message(
      'Wrong device assignment to retail chain.',
      name: 'wrong_device_to_retail_chain',
      desc: '',
      args: [],
    );
  }

  /// `Wrong user assignment to retail chain.`
  String get wrong_user_to_retail_chain {
    return Intl.message(
      'Wrong user assignment to retail chain.',
      name: 'wrong_user_to_retail_chain',
      desc: '',
      args: [],
    );
  }

  /// `Wrong device assignment to collection point.`
  String get wrong_device_to_collection_point {
    return Intl.message(
      'Wrong device assignment to collection point.',
      name: 'wrong_device_to_collection_point',
      desc: '',
      args: [],
    );
  }

  /// `Wrong user assignment to collection point.`
  String get wrong_user_to_collection_point {
    return Intl.message(
      'Wrong user assignment to collection point.',
      name: 'wrong_user_to_collection_point',
      desc: '',
      args: [],
    );
  }

  /// `Item with given ID is not assigned to your Counting Center`
  String get item_incorrect_cc {
    return Intl.message(
      'Item with given ID is not assigned to your Counting Center',
      name: 'item_incorrect_cc',
      desc: '',
      args: [],
    );
  }

  /// `Item with given ID has not been released`
  String get item_not_released {
    return Intl.message(
      'Item with given ID has not been released',
      name: 'item_not_released',
      desc: '',
      args: [],
    );
  }

  /// `Package receival confirmed`
  String get packages_receival_confirmation {
    return Intl.message(
      'Package receival confirmed',
      name: 'packages_receival_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `You are not authorized for this action`
  String get user_not_authorized {
    return Intl.message(
      'You are not authorized for this action',
      name: 'user_not_authorized',
      desc: '',
      args: [],
    );
  }

  /// `Bag has not been released`
  String get bag_not_released {
    return Intl.message(
      'Bag has not been released',
      name: 'bag_not_released',
      desc: '',
      args: [],
    );
  }

  /// `Token not provided`
  String get token_not_provided {
    return Intl.message(
      'Token not provided',
      name: 'token_not_provided',
      desc: '',
      args: [],
    );
  }

  /// `Pickup with given ID not found`
  String get pickup_not_found {
    return Intl.message(
      'Pickup with given ID not found',
      name: 'pickup_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Counting Center with given ID not found`
  String get cc_not_found {
    return Intl.message(
      'Counting Center with given ID not found',
      name: 'cc_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Counting Center number missing`
  String get cc_empty {
    return Intl.message(
      'Counting Center number missing',
      name: 'cc_empty',
      desc: '',
      args: [],
    );
  }

  /// `Device not configured correctly.`
  String get device_not_configured {
    return Intl.message(
      'Device not configured correctly.',
      name: 'device_not_configured',
      desc: '',
      args: [],
    );
  }

  /// `User not configured correctly.`
  String get wrong_user_configuration {
    return Intl.message(
      'User not configured correctly.',
      name: 'wrong_user_configuration',
      desc: '',
      args: [],
    );
  }

  /// `Bag has already been received`
  String get bag_already_received {
    return Intl.message(
      'Bag has already been received',
      name: 'bag_already_received',
      desc: '',
      args: [],
    );
  }

  /// `Bags`
  String get bags {
    return Intl.message('Bags', name: 'bags', desc: '', args: []);
  }

  /// `Collection units`
  String get boxes {
    return Intl.message('Collection units', name: 'boxes', desc: '', args: []);
  }

  /// `Packages in bag list`
  String get packages_in_bag {
    return Intl.message(
      'Packages in bag list',
      name: 'packages_in_bag',
      desc: '',
      args: [],
    );
  }

  /// `Last added EAN`
  String get last_added_ean {
    return Intl.message(
      'Last added EAN',
      name: 'last_added_ean',
      desc: '',
      args: [],
    );
  }

  /// `Bag with this number has already been added to pickup.`
  String get bag_already_added_to_pickup {
    return Intl.message(
      'Bag with this number has already been added to pickup.',
      name: 'bag_already_added_to_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Bag with this number has already been added to receival.`
  String get bag_already_added_to_receival {
    return Intl.message(
      'Bag with this number has already been added to receival.',
      name: 'bag_already_added_to_receival',
      desc: '',
      args: [],
    );
  }

  /// `Bag with given ID is not assigned to your collection point`
  String get bag_incorrect_collection_point {
    return Intl.message(
      'Bag with given ID is not assigned to your collection point',
      name: 'bag_incorrect_collection_point',
      desc: '',
      args: [],
    );
  }

  /// `Package has different type than bag`
  String get bag_incorrect_item_for_bag {
    return Intl.message(
      'Package has different type than bag',
      name: 'bag_incorrect_item_for_bag',
      desc: '',
      args: [],
    );
  }

  /// `EAN cannot be empty`
  String get ean_empty {
    return Intl.message(
      'EAN cannot be empty',
      name: 'ean_empty',
      desc: '',
      args: [],
    );
  }

  /// `Package with given EAN not found`
  String get ean_not_found {
    return Intl.message(
      'Package with given EAN not found',
      name: 'ean_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Quantity must be greater than zero`
  String get quantity_less_or_equal_zero {
    return Intl.message(
      'Quantity must be greater than zero',
      name: 'quantity_less_or_equal_zero',
      desc: '',
      args: [],
    );
  }

  /// `Device ID cannot be empty`
  String get device_id_empty {
    return Intl.message(
      'Device ID cannot be empty',
      name: 'device_id_empty',
      desc: '',
      args: [],
    );
  }

  /// `Device ID too long`
  String get device_id_too_long {
    return Intl.message(
      'Device ID too long',
      name: 'device_id_too_long',
      desc: '',
      args: [],
    );
  }

  /// `Invalid device ID`
  String get invalid_device_id {
    return Intl.message(
      'Invalid device ID',
      name: 'invalid_device_id',
      desc: '',
      args: [],
    );
  }

  /// `Bag contains packages from open return. Close return`
  String get bag_contains_open_return_packages {
    return Intl.message(
      'Bag contains packages from open return. Close return',
      name: 'bag_contains_open_return_packages',
      desc: '',
      args: [],
    );
  }

  /// `Scan new seal`
  String get scan_new_seal {
    return Intl.message(
      'Scan new seal',
      name: 'scan_new_seal',
      desc: '',
      args: [],
    );
  }

  /// `Package receival confirmed. Note: Some bags in this receival were already scanned. System recognizes them as one operation and requires no additional action.`
  String get packages_receival_confirmation_duplicates {
    return Intl.message(
      'Package receival confirmed. Note: Some bags in this receival were already scanned. System recognizes them as one operation and requires no additional action.',
      name: 'packages_receival_confirmation_duplicates',
      desc: '',
      args: [],
    );
  }

  /// `Returning packages list`
  String get returning_packages_list {
    return Intl.message(
      'Returning packages list',
      name: 'returning_packages_list',
      desc: '',
      args: [],
    );
  }

  /// `Package return completion confirmation`
  String get return_finish_confirmation {
    return Intl.message(
      'Package return completion confirmation',
      name: 'return_finish_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Empty bag cannot be closed`
  String get empty_bag_cannot_be_closed {
    return Intl.message(
      'Empty bag cannot be closed',
      name: 'empty_bag_cannot_be_closed',
      desc: '',
      args: [],
    );
  }

  /// `Change label/bag`
  String get change_label_or_bag {
    return Intl.message(
      'Change label/bag',
      name: 'change_label_or_bag',
      desc: '',
      args: [],
    );
  }

  /// `Choose reason for label/bag change:`
  String get choose_reason_for_label_or_bag_change {
    return Intl.message(
      'Choose reason for label/bag change:',
      name: 'choose_reason_for_label_or_bag_change',
      desc: '',
      args: [],
    );
  }

  /// `Environment`
  String get environment {
    return Intl.message('Environment', name: 'environment', desc: '', args: []);
  }

  /// `If you see this screen, it means the service is working correctly.`
  String get if_you_see_this_screen {
    return Intl.message(
      'If you see this screen, it means the service is working correctly.',
      name: 'if_you_see_this_screen',
      desc: '',
      args: [],
    );
  }

  /// `Request sent to Application Insights service`
  String get insights_request_sent {
    return Intl.message(
      'Request sent to Application Insights service',
      name: 'insights_request_sent',
      desc: '',
      args: [],
    );
  }

  /// `Test Application Insights`
  String get test_application_insights {
    return Intl.message(
      'Test Application Insights',
      name: 'test_application_insights',
      desc: '',
      args: [],
    );
  }

  /// `Print pickup confirmation`
  String get print_pickup_confirmation {
    return Intl.message(
      'Print pickup confirmation',
      name: 'print_pickup_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Pickup confirmation document has been printed again.`
  String get pickup_confirmation_printed_again {
    return Intl.message(
      'Pickup confirmation document has been printed again.',
      name: 'pickup_confirmation_printed_again',
      desc: '',
      args: [],
    );
  }

  /// `Receival`
  String get receival {
    return Intl.message('Receival', name: 'receival', desc: '', args: []);
  }

  /// `Bag selected for sealing.`
  String get bag_selected_for_closing {
    return Intl.message(
      'Bag selected for sealing.',
      name: 'bag_selected_for_closing',
      desc: '',
      args: [],
    );
  }

  /// `Two copies of pickup confirmation will be printed. Sign and give them to the driver!`
  String get pickup_confirmation_subtitle {
    return Intl.message(
      'Two copies of pickup confirmation will be printed. Sign and give them to the driver!',
      name: 'pickup_confirmation_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred. Try again or contact administrator.`
  String get generic_error_message {
    return Intl.message(
      'An error occurred. Try again or contact administrator.',
      name: 'generic_error_message',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Open bag`
  String get open_bag {
    return Intl.message('Open bag', name: 'open_bag', desc: '', args: []);
  }

  /// `Label`
  String get label {
    return Intl.message('Label', name: 'label', desc: '', args: []);
  }

  /// `Sealed bag`
  String get sealed_bag {
    return Intl.message('Sealed bag', name: 'sealed_bag', desc: '', args: []);
  }

  /// `Seal`
  String get seal {
    return Intl.message('Seal', name: 'seal', desc: '', args: []);
  }

  /// `Bag selected for label change.`
  String get bag_selected_for_label_change {
    return Intl.message(
      'Bag selected for label change.',
      name: 'bag_selected_for_label_change',
      desc: '',
      args: [],
    );
  }

  /// `Bag selected for seal change.`
  String get bag_selected_for_seal_change {
    return Intl.message(
      'Bag selected for seal change.',
      name: 'bag_selected_for_seal_change',
      desc: '',
      args: [],
    );
  }

  /// `Bag opened correctly`
  String get bag_correctly_opened {
    return Intl.message(
      'Bag opened correctly',
      name: 'bag_correctly_opened',
      desc: '',
      args: [],
    );
  }

  /// `Invalid seal format`
  String get invalid_seal_format {
    return Intl.message(
      'Invalid seal format',
      name: 'invalid_seal_format',
      desc: '',
      args: [],
    );
  }

  /// `Current return`
  String get current_return {
    return Intl.message(
      'Current return',
      name: 'current_return',
      desc: '',
      args: [],
    );
  }

  /// `Refresh remote configuration`
  String get refresh_remote_config {
    return Intl.message(
      'Refresh remote configuration',
      name: 'refresh_remote_config',
      desc: '',
      args: [],
    );
  }

  /// `Correct print`
  String get correct_print {
    return Intl.message(
      'Correct print',
      name: 'correct_print',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled print`
  String get cancelled_print {
    return Intl.message(
      'Cancelled print',
      name: 'cancelled_print',
      desc: '',
      args: [],
    );
  }

  /// `Before print`
  String get before_print {
    return Intl.message(
      'Before print',
      name: 'before_print',
      desc: '',
      args: [],
    );
  }

  /// `No returns for selected date.`
  String get no_returns_selected_date {
    return Intl.message(
      'No returns for selected date.',
      name: 'no_returns_selected_date',
      desc: '',
      args: [],
    );
  }

  /// `Current release`
  String get current_release {
    return Intl.message(
      'Current release',
      name: 'current_release',
      desc: '',
      args: [],
    );
  }

  /// `Added bags list`
  String get list_of_added_bags {
    return Intl.message(
      'Added bags list',
      name: 'list_of_added_bags',
      desc: '',
      args: [],
    );
  }

  /// `Bags in pickup list`
  String get list_of_bags_in_pickup {
    return Intl.message(
      'Bags in pickup list',
      name: 'list_of_bags_in_pickup',
      desc: '',
      args: [],
    );
  }

  /// `No bags in current pickup.`
  String get no_bags_in_current_pickup {
    return Intl.message(
      'No bags in current pickup.',
      name: 'no_bags_in_current_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Scan bag seal code and add bag to pickup`
  String get scan_bag_seal_code_pickup {
    return Intl.message(
      'Scan bag seal code and add bag to pickup',
      name: 'scan_bag_seal_code_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Bag summary`
  String get bag_summary {
    return Intl.message('Bag summary', name: 'bag_summary', desc: '', args: []);
  }

  /// `Sealed`
  String get sealed {
    return Intl.message('Sealed', name: 'sealed', desc: '', args: []);
  }

  /// `EAN`
  String get ean {
    return Intl.message('EAN', name: 'ean', desc: '', args: []);
  }

  /// `Seal another bag`
  String get seal_another_bag {
    return Intl.message(
      'Seal another bag',
      name: 'seal_another_bag',
      desc: '',
      args: [],
    );
  }

  /// `Seal bag`
  String get seal_bag {
    return Intl.message('Seal bag', name: 'seal_bag', desc: '', args: []);
  }

  /// `Scan new bag label code`
  String get scan_new_bag_label_code {
    return Intl.message(
      'Scan new bag label code',
      name: 'scan_new_bag_label_code',
      desc: '',
      args: [],
    );
  }

  /// `or enter label number`
  String get or_enter_label_number {
    return Intl.message(
      'or enter label number',
      name: 'or_enter_label_number',
      desc: '',
      args: [],
    );
  }

  /// `Seal has been added correctly.`
  String get seal_was_added_successfully {
    return Intl.message(
      'Seal has been added correctly.',
      name: 'seal_was_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Printer configuration error - make sure selected printer is correctly configured.`
  String get printer_bluetooth_address_not_valid_error_message {
    return Intl.message(
      'Printer configuration error - make sure selected printer is correctly configured.',
      name: 'printer_bluetooth_address_not_valid_error_message',
      desc: '',
      args: [],
    );
  }

  /// `Print error: make sure printer is turned on and properly connected.`
  String get printer_not_turned_on_error_message {
    return Intl.message(
      'Print error: make sure printer is turned on and properly connected.',
      name: 'printer_not_turned_on_error_message',
      desc: '',
      args: [],
    );
  }

  /// `Print error: no printer connection. Check if Bluetooth is on and try again.`
  String get printer_bluetooth_not_turned_on_error_message {
    return Intl.message(
      'Print error: no printer connection. Check if Bluetooth is on and try again.',
      name: 'printer_bluetooth_not_turned_on_error_message',
      desc: '',
      args: [],
    );
  }

  /// `Cannot print document. Check printer configuration and device connection, then try again.`
  String get general_printer_error_message {
    return Intl.message(
      'Cannot print document. Check printer configuration and device connection, then try again.',
      name: 'general_printer_error_message',
      desc: '',
      args: [],
    );
  }

  /// `Sealed bags list`
  String get sealed_bags_list {
    return Intl.message(
      'Sealed bags list',
      name: 'sealed_bags_list',
      desc: '',
      args: [],
    );
  }

  /// `Current receival`
  String get current_receival {
    return Intl.message(
      'Current receival',
      name: 'current_receival',
      desc: '',
      args: [],
    );
  }

  /// `Glass package return`
  String get glass_return {
    return Intl.message(
      'Glass package return',
      name: 'glass_return',
      desc: '',
      args: [],
    );
  }

  /// `Package return: Plastic, Can`
  String get return_plastics_cans {
    return Intl.message(
      'Package return: Plastic, Can',
      name: 'return_plastics_cans',
      desc: '',
      args: [],
    );
  }

  /// `Package return: Glass`
  String get return_glass_bottles {
    return Intl.message(
      'Package return: Glass',
      name: 'return_glass_bottles',
      desc: '',
      args: [],
    );
  }

  /// `Glass package return`
  String get return_glass_bottles_title {
    return Intl.message(
      'Glass package return',
      name: 'return_glass_bottles_title',
      desc: '',
      args: [],
    );
  }

  /// `No received bags.`
  String get no_received_bags {
    return Intl.message(
      'No received bags.',
      name: 'no_received_bags',
      desc: '',
      args: [],
    );
  }

  /// `Glass`
  String get glass {
    return Intl.message('Glass', name: 'glass', desc: '', args: []);
  }

  /// `Deposit voucher`
  String get security_deposit_voucher {
    return Intl.message(
      'Deposit voucher',
      name: 'security_deposit_voucher',
      desc: '',
      args: [],
    );
  }

  /// `Voucher generation date`
  String get voucher_generation_date {
    return Intl.message(
      'Voucher generation date',
      name: 'voucher_generation_date',
      desc: '',
      args: [],
    );
  }

  /// `Expiration date`
  String get expiration_date {
    return Intl.message(
      'Expiration date',
      name: 'expiration_date',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get days {
    return Intl.message('days', name: 'days', desc: '', args: []);
  }

  /// `Sum PLN`
  String get pln_sum {
    return Intl.message('Sum PLN', name: 'pln_sum', desc: '', args: []);
  }

  /// `Show voucher`
  String get show_voucher {
    return Intl.message(
      'Show voucher',
      name: 'show_voucher',
      desc: '',
      args: [],
    );
  }

  /// `Return has been closed. Show voucher.`
  String get return_closed_show_voucher {
    return Intl.message(
      'Return has been closed. Show voucher.',
      name: 'return_closed_show_voucher',
      desc: '',
      args: [],
    );
  }

  /// `Selected bag for packages`
  String get chosen_bag_for_packages {
    return Intl.message(
      'Selected bag for packages',
      name: 'chosen_bag_for_packages',
      desc: '',
      args: [],
    );
  }

  /// `Full package list in current return`
  String get actual_return_full_packages_list {
    return Intl.message(
      'Full package list in current return',
      name: 'actual_return_full_packages_list',
      desc: '',
      args: [],
    );
  }

  /// `Scanned package type is not supported at your collection point.`
  String get scanned_package_of_not_allowed_type {
    return Intl.message(
      'Scanned package type is not supported at your collection point.',
      name: 'scanned_package_of_not_allowed_type',
      desc: '',
      args: [],
    );
  }

  /// `Scanned package must be assigned to a bag.`
  String get scanned_package_must_be_assigned_to_bag {
    return Intl.message(
      'Scanned package must be assigned to a bag.',
      name: 'scanned_package_must_be_assigned_to_bag',
      desc: '',
      args: [],
    );
  }

  /// `Bag choice`
  String get bag_choice {
    return Intl.message('Bag choice', name: 'bag_choice', desc: '', args: []);
  }

  /// `Bag selected correctly.`
  String get bag_correctly_chosen {
    return Intl.message(
      'Bag selected correctly.',
      name: 'bag_correctly_chosen',
      desc: '',
      args: [],
    );
  }

  /// `Last scanned package has been removed from returning packages list in current return.`
  String get last_package_removed_from_return {
    return Intl.message(
      'Last scanned package has been removed from returning packages list in current return.',
      name: 'last_package_removed_from_return',
      desc: '',
      args: [],
    );
  }

  /// `Scanned package requires bag change.`
  String get scanned_package_requires_bag_change {
    return Intl.message(
      'Scanned package requires bag change.',
      name: 'scanned_package_requires_bag_change',
      desc: '',
      args: [],
    );
  }

  /// `I accept terms and conditions`
  String get accept_terms_and_conditions {
    return Intl.message(
      'I accept terms and conditions',
      name: 'accept_terms_and_conditions',
      desc: '',
      args: [],
    );
  }

  /// `Accept terms`
  String get accept_terms {
    return Intl.message(
      'Accept terms',
      name: 'accept_terms',
      desc: '',
      args: [],
    );
  }

  /// `In today's digital world, where data has become a key resource, OK OPERATOR KAUCYJNY S.A. recognizes personal data protection as a fundamental element of our operations. We are deeply convinced that the trust of people who use our services and our contractors is not only a privilege, but also an obligation that we treat with the utmost seriousness.`
  String get terms_and_conditions_part_1 {
    return Intl.message(
      'In today\'s digital world, where data has become a key resource, OK OPERATOR KAUCYJNY S.A. recognizes personal data protection as a fundamental element of our operations. We are deeply convinced that the trust of people who use our services and our contractors is not only a privilege, but also an obligation that we treat with the utmost seriousness.',
      name: 'terms_and_conditions_part_1',
      desc: '',
      args: [],
    );
  }

  /// `Our company, operating in the deposit industry, realizes that effective personal data protection is crucial for maintaining the integrity of our business processes, building long-term relationships with partners, and ensuring compliance with applicable laws. Therefore, personal data protection is not only a legal obligation for us, but is an integral part of our organizational culture and business ethics.`
  String get terms_and_conditions_part_2 {
    return Intl.message(
      'Our company, operating in the deposit industry, realizes that effective personal data protection is crucial for maintaining the integrity of our business processes, building long-term relationships with partners, and ensuring compliance with applicable laws. Therefore, personal data protection is not only a legal obligation for us, but is an integral part of our organizational culture and business ethics.',
      name: 'terms_and_conditions_part_2',
      desc: '',
      args: [],
    );
  }

  /// `At OK OPERATOR KAUCYJNY S.A. we believe that transparency in personal data processing is the foundation of trust in business relationships. Therefore, we make every effort to provide our partners and customers with full transparency regarding how we collect, process and protect their personal data. Our privacy policy is an expression of this commitment - it is a comprehensive guide to our data protection practices.`
  String get terms_and_conditions_part_3 {
    return Intl.message(
      'At OK OPERATOR KAUCYJNY S.A. we believe that transparency in personal data processing is the foundation of trust in business relationships. Therefore, we make every effort to provide our partners and customers with full transparency regarding how we collect, process and protect their personal data. Our privacy policy is an expression of this commitment - it is a comprehensive guide to our data protection practices.',
      name: 'terms_and_conditions_part_3',
      desc: '',
      args: [],
    );
  }

  /// `We invest significant resources in the most modern technological and organizational solutions to guarantee the highest level of security for the data entrusted to us. We regularly conduct audits and updates of our systems to meet the constantly evolving threats in cyberspace. At the same time, we provide ongoing training to our employees so that they are fully aware of the importance of personal data protection and know the best practices in this area.`
  String get terms_and_conditions_part_4 {
    return Intl.message(
      'We invest significant resources in the most modern technological and organizational solutions to guarantee the highest level of security for the data entrusted to us. We regularly conduct audits and updates of our systems to meet the constantly evolving threats in cyberspace. At the same time, we provide ongoing training to our employees so that they are fully aware of the importance of personal data protection and know the best practices in this area.',
      name: 'terms_and_conditions_part_4',
      desc: '',
      args: [],
    );
  }

  /// `We understand that in a dynamic business environment, effective information exchange is crucial for success. Therefore, while caring for data protection, we strive to simultaneously ensure business process fluidity for our partners and customers. Our privacy policy is designed to enable effective cooperation while maintaining the highest data protection standards.`
  String get terms_and_conditions_part_5 {
    return Intl.message(
      'We understand that in a dynamic business environment, effective information exchange is crucial for success. Therefore, while caring for data protection, we strive to simultaneously ensure business process fluidity for our partners and customers. Our privacy policy is designed to enable effective cooperation while maintaining the highest data protection standards.',
      name: 'terms_and_conditions_part_5',
      desc: '',
      args: [],
    );
  }

  /// `At OK OPERATOR KAUCYJNY S.A. we are convinced that responsible personal data management is not only a legal obligation, but also a key factor in building trust and loyalty of our business partners and customers. Therefore, we commit to continuously improving our data protection practices, adapting to changing legal and technological realities, and maintaining open dialogue with our stakeholders on data privacy issues.`
  String get terms_and_conditions_part_6 {
    return Intl.message(
      'At OK OPERATOR KAUCYJNY S.A. we are convinced that responsible personal data management is not only a legal obligation, but also a key factor in building trust and loyalty of our business partners and customers. Therefore, we commit to continuously improving our data protection practices, adapting to changing legal and technological realities, and maintaining open dialogue with our stakeholders on data privacy issues.',
      name: 'terms_and_conditions_part_6',
      desc: '',
      args: [],
    );
  }

  /// `We invite you to read our detailed privacy policy, which reflects our commitment to protecting your personal data. We are convinced that through these actions we build not only secure, but also lasting business relationships, based on mutual trust and respect for privacy.`
  String get terms_and_conditions_part_7 {
    return Intl.message(
      'We invite you to read our detailed privacy policy, which reflects our commitment to protecting your personal data. We are convinced that through these actions we build not only secure, but also lasting business relationships, based on mutual trust and respect for privacy.',
      name: 'terms_and_conditions_part_7',
      desc: '',
      args: [],
    );
  }

  /// `OK mobile app terms and conditions`
  String get terms_and_conditions_title {
    return Intl.message(
      'OK mobile app terms and conditions',
      name: 'terms_and_conditions_title',
      desc: '',
      args: [],
    );
  }

  /// `I. Introduction: Our commitment to protecting our users' data`
  String get terms_and_condition_paragraph_1 {
    return Intl.message(
      'I. Introduction: Our commitment to protecting our users\' data',
      name: 'terms_and_condition_paragraph_1',
      desc: '',
      args: [],
    );
  }

  /// `Invalid package type`
  String get invalid_package_type {
    return Intl.message(
      'Invalid package type',
      name: 'invalid_package_type',
      desc: '',
      args: [],
    );
  }

  /// `Selected bag is closed, please scan the label of an open bag.`
  String get bag_closed_choose_open_instead {
    return Intl.message(
      'Selected bag is closed, please scan the label of an open bag.',
      name: 'bag_closed_choose_open_instead',
      desc: '',
      args: [],
    );
  }

  /// `The last package was not assigned to an open bag and has been removed from the list. Please scan the package EAN again.`
  String get last_package_not_assigned_and_removed {
    return Intl.message(
      'The last package was not assigned to an open bag and has been removed from the list. Please scan the package EAN again.',
      name: 'last_package_not_assigned_and_removed',
      desc: '',
      args: [],
    );
  }

  /// `Logout process cancelled`
  String get logout_cancelled {
    return Intl.message(
      'Logout process cancelled',
      name: 'logout_cancelled',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'uk'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
