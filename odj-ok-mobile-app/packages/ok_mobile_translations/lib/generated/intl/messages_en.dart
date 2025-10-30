// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(id) => "Selected bag ${id}.";

  static String m1(id, type) => "Selected ${type} bag ${id}.";

  static String m2(id) => "New bag ${id} opened correctly.";

  static String m3(mac_address) => "Selected printer ${mac_address}";

  static String m4(day) => "Selected day: ${day}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept_terms": MessageLookupByLibrary.simpleMessage("Accept terms"),
    "accept_terms_and_conditions": MessageLookupByLibrary.simpleMessage(
      "I accept terms and conditions",
    ),
    "actual_return_full_packages_list": MessageLookupByLibrary.simpleMessage(
      "Full package list in current return",
    ),
    "add_bags_to_box": MessageLookupByLibrary.simpleMessage(
      "Add bags to collection unit",
    ),
    "add_printer_to_start_pickup": MessageLookupByLibrary.simpleMessage(
      "Add printer to start pickup",
    ),
    "add_printer_to_start_return": MessageLookupByLibrary.simpleMessage(
      "Add printer to start deposit package return",
    ),
    "add_seal": MessageLookupByLibrary.simpleMessage("Add seal"),
    "add_to_box": MessageLookupByLibrary.simpleMessage(
      "Add to collection unit",
    ),
    "added_seal": MessageLookupByLibrary.simpleMessage("Added seal"),
    "admin": MessageLookupByLibrary.simpleMessage("Administration"),
    "all_bags_added_to_box": MessageLookupByLibrary.simpleMessage(
      "Bags have been added to collection unit",
    ),
    "all_boxes_closed": MessageLookupByLibrary.simpleMessage(
      "All collection units have been closed",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "bag": MessageLookupByLibrary.simpleMessage("Bag"),
    "bag_already_added_to_box": MessageLookupByLibrary.simpleMessage(
      "This bag is already assigned to a collection unit",
    ),
    "bag_already_added_to_pickup": MessageLookupByLibrary.simpleMessage(
      "Bag with this number has already been added to pickup.",
    ),
    "bag_already_added_to_receival": MessageLookupByLibrary.simpleMessage(
      "Bag with this number has already been added to receival.",
    ),
    "bag_already_closed": MessageLookupByLibrary.simpleMessage(
      "Bag is already closed.",
    ),
    "bag_already_received": MessageLookupByLibrary.simpleMessage(
      "Bag has already been received",
    ),
    "bag_choice": MessageLookupByLibrary.simpleMessage("Bag choice"),
    "bag_chosen": MessageLookupByLibrary.simpleMessage("Bag selected"),
    "bag_closed_choose_open_instead": MessageLookupByLibrary.simpleMessage(
      "Selected bag is closed, please scan the label of an open bag.",
    ),
    "bag_contains_open_return_packages": MessageLookupByLibrary.simpleMessage(
      "Bag contains packages from open return. Close return",
    ),
    "bag_correctly_chosen": MessageLookupByLibrary.simpleMessage(
      "Bag selected correctly.",
    ),
    "bag_correctly_opened": MessageLookupByLibrary.simpleMessage(
      "Bag opened correctly",
    ),
    "bag_empty": MessageLookupByLibrary.simpleMessage(
      "Bag number cannot be empty",
    ),
    "bag_incorrect_collection_point": MessageLookupByLibrary.simpleMessage(
      "Bag with given ID is not assigned to your collection point",
    ),
    "bag_incorrect_item_for_bag": MessageLookupByLibrary.simpleMessage(
      "Package has different type than bag",
    ),
    "bag_is_open": MessageLookupByLibrary.simpleMessage("Bag is open"),
    "bag_not_assigned_to_collection_point":
        MessageLookupByLibrary.simpleMessage(
          "This bag is not assigned to your collection point",
        ),
    "bag_not_closed": MessageLookupByLibrary.simpleMessage(
      "Bag cannot be added to collection unit because it is not closed.",
    ),
    "bag_not_found": MessageLookupByLibrary.simpleMessage(
      "Bag with given code not found",
    ),
    "bag_not_released": MessageLookupByLibrary.simpleMessage(
      "Bag has not been released",
    ),
    "bag_selected_for_closing": MessageLookupByLibrary.simpleMessage(
      "Bag selected for sealing.",
    ),
    "bag_selected_for_label_change": MessageLookupByLibrary.simpleMessage(
      "Bag selected for label change.",
    ),
    "bag_selected_for_seal_change": MessageLookupByLibrary.simpleMessage(
      "Bag selected for seal change.",
    ),
    "bag_summary": MessageLookupByLibrary.simpleMessage("Bag summary"),
    "bag_was_added_to_box": MessageLookupByLibrary.simpleMessage(
      "Bag has been added to collection unit",
    ),
    "bag_was_chosen": m0,
    "bag_was_chosen_with_type": m1,
    "bag_was_closed": MessageLookupByLibrary.simpleMessage(
      "Bag has been closed.",
    ),
    "bag_was_removed_from_box": MessageLookupByLibrary.simpleMessage(
      "Bag has been removed from collection unit",
    ),
    "bags": MessageLookupByLibrary.simpleMessage("Bags"),
    "bags_management": MessageLookupByLibrary.simpleMessage("Bag management"),
    "before_print": MessageLookupByLibrary.simpleMessage("Before print"),
    "box": MessageLookupByLibrary.simpleMessage("Collection unit"),
    "box_already_closed": MessageLookupByLibrary.simpleMessage(
      "Collection unit has already been closed",
    ),
    "box_correctly_opened": MessageLookupByLibrary.simpleMessage(
      "Collection unit opened correctly",
    ),
    "box_empty": MessageLookupByLibrary.simpleMessage(
      "Collection unit number cannot be empty",
    ),
    "box_ids_empty": MessageLookupByLibrary.simpleMessage(
      "Collection unit ID list cannot be empty",
    ),
    "box_not_assigned_to_collection_point":
        MessageLookupByLibrary.simpleMessage(
          "This collection unit is not assigned to your collection point",
        ),
    "box_not_found": MessageLookupByLibrary.simpleMessage(
      "Collection unit not found",
    ),
    "box_summary": MessageLookupByLibrary.simpleMessage(
      "Collection unit summary",
    ),
    "box_was_closed": MessageLookupByLibrary.simpleMessage(
      "Collection unit has been closed",
    ),
    "boxes": MessageLookupByLibrary.simpleMessage("Collection units"),
    "camera_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Camera access denied",
    ),
    "can": MessageLookupByLibrary.simpleMessage("Can"),
    "can_quantity": MessageLookupByLibrary.simpleMessage("Cans (pieces):"),
    "cancel_voucher_print": MessageLookupByLibrary.simpleMessage(
      "Cancel voucher print",
    ),
    "canceled": MessageLookupByLibrary.simpleMessage("Canceled"),
    "cancelled_print": MessageLookupByLibrary.simpleMessage("Cancelled print"),
    "cc_empty": MessageLookupByLibrary.simpleMessage(
      "Counting Center number missing",
    ),
    "cc_not_found": MessageLookupByLibrary.simpleMessage(
      "Counting Center with given ID not found",
    ),
    "change_bag": MessageLookupByLibrary.simpleMessage("Change bag"),
    "change_box_label": MessageLookupByLibrary.simpleMessage(
      "Change collection unit label",
    ),
    "change_label": MessageLookupByLibrary.simpleMessage("Change label"),
    "change_label_or_bag": MessageLookupByLibrary.simpleMessage(
      "Change label/bag",
    ),
    "change_seal": MessageLookupByLibrary.simpleMessage("Change seal"),
    "change_seal_after_label_change": MessageLookupByLibrary.simpleMessage(
      "For sealed bags, both label and seal must be replaced.",
    ),
    "choose_open_bag": MessageLookupByLibrary.simpleMessage("Choose open bag"),
    "choose_open_bag_CAN": MessageLookupByLibrary.simpleMessage(
      "Choose open can bag",
    ),
    "choose_open_bag_plastic": MessageLookupByLibrary.simpleMessage(
      "Choose open plastic bag",
    ),
    "choose_open_box": MessageLookupByLibrary.simpleMessage(
      "Choose open collection unit",
    ),
    "choose_reason_for_label_change": MessageLookupByLibrary.simpleMessage(
      "Choose reason for label change",
    ),
    "choose_reason_for_label_or_bag_change":
        MessageLookupByLibrary.simpleMessage(
          "Choose reason for label/bag change:",
        ),
    "choose_reason_for_seal_change": MessageLookupByLibrary.simpleMessage(
      "Choose reason for seal change:",
    ),
    "choose_voucher_print_reason": MessageLookupByLibrary.simpleMessage(
      "Choose voucher print reason:",
    ),
    "choose_voucher_reprint_reason": MessageLookupByLibrary.simpleMessage(
      "Choose voucher reprint reason:",
    ),
    "chosen_bag": MessageLookupByLibrary.simpleMessage("Selected bag"),
    "chosen_bag_for_packages": MessageLookupByLibrary.simpleMessage(
      "Selected bag for packages",
    ),
    "chosen_printer": MessageLookupByLibrary.simpleMessage("Selected printer"),
    "client_resignation": MessageLookupByLibrary.simpleMessage(
      "Client cancellation",
    ),
    "close_and_seal": MessageLookupByLibrary.simpleMessage(
      "Close and seal bag",
    ),
    "close_bag": MessageLookupByLibrary.simpleMessage("Close bag"),
    "close_box": MessageLookupByLibrary.simpleMessage("Close collection unit"),
    "close_boxes": MessageLookupByLibrary.simpleMessage(
      "Close collection units",
    ),
    "closed": MessageLookupByLibrary.simpleMessage("Closed"),
    "closed_bag": MessageLookupByLibrary.simpleMessage("Closed bag"),
    "closed_bags": MessageLookupByLibrary.simpleMessage("Closed bags"),
    "closed_bags_list": MessageLookupByLibrary.simpleMessage(
      "Closed bags list",
    ),
    "closed_returns": MessageLookupByLibrary.simpleMessage("Closed returns"),
    "closed_returns_archive": MessageLookupByLibrary.simpleMessage(
      "Closed returns archive",
    ),
    "closed_returns_list": MessageLookupByLibrary.simpleMessage(
      "Closed returns list",
    ),
    "collected_packages": MessageLookupByLibrary.simpleMessage(
      "Collected packages",
    ),
    "collection_point_id_empty": MessageLookupByLibrary.simpleMessage(
      "Collection point ID cannot be empty",
    ),
    "collection_point_not_exist": MessageLookupByLibrary.simpleMessage(
      "Collection point with given ID does not exist",
    ),
    "comment_empty": MessageLookupByLibrary.simpleMessage(
      "Comment cannot be empty",
    ),
    "configure_printer": MessageLookupByLibrary.simpleMessage(
      "Configure printer",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirm_and_print_document": MessageLookupByLibrary.simpleMessage(
      "Confirm and print document",
    ),
    "confirm_pickup": MessageLookupByLibrary.simpleMessage("Confirm pickup"),
    "confirm_receival": MessageLookupByLibrary.simpleMessage(
      "Confirm receival",
    ),
    "confirm_voucher_print": MessageLookupByLibrary.simpleMessage(
      "I confirm voucher print for return",
    ),
    "contact_admin": MessageLookupByLibrary.simpleMessage(
      "Contact Administrator to fix this issue.",
    ),
    "correct": MessageLookupByLibrary.simpleMessage("Correct"),
    "correct_print": MessageLookupByLibrary.simpleMessage("Correct print"),
    "current_receival": MessageLookupByLibrary.simpleMessage(
      "Current receival",
    ),
    "current_release": MessageLookupByLibrary.simpleMessage("Current release"),
    "current_return": MessageLookupByLibrary.simpleMessage("Current return"),
    "damaged_bag": MessageLookupByLibrary.simpleMessage("Damaged bag"),
    "damaged_label": MessageLookupByLibrary.simpleMessage("Damaged label"),
    "damaged_seal": MessageLookupByLibrary.simpleMessage("Damaged seal"),
    "days": MessageLookupByLibrary.simpleMessage("days"),
    "declare_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Declare for pickup",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "device_id_empty": MessageLookupByLibrary.simpleMessage(
      "Device ID cannot be empty",
    ),
    "device_id_too_long": MessageLookupByLibrary.simpleMessage(
      "Device ID too long",
    ),
    "device_not_configured": MessageLookupByLibrary.simpleMessage(
      "Device not configured correctly.",
    ),
    "different_issue": MessageLookupByLibrary.simpleMessage("Other issue"),
    "different_reason": MessageLookupByLibrary.simpleMessage("Other reason"),
    "do_you_really_want_to_close": MessageLookupByLibrary.simpleMessage(
      "Do you really want to confirm closing",
    ),
    "duplicated_label_error": MessageLookupByLibrary.simpleMessage(
      "Bag with this number already exists - change label.",
    ),
    "ean": MessageLookupByLibrary.simpleMessage("EAN"),
    "ean_empty": MessageLookupByLibrary.simpleMessage("EAN cannot be empty"),
    "ean_not_found": MessageLookupByLibrary.simpleMessage(
      "Package with given EAN not found",
    ),
    "empty": MessageLookupByLibrary.simpleMessage("EMPTY"),
    "empty_bag_cannot_be_closed": MessageLookupByLibrary.simpleMessage(
      "Empty bag cannot be closed",
    ),
    "enter_bag_number": MessageLookupByLibrary.simpleMessage(
      "Enter bag number",
    ),
    "environment": MessageLookupByLibrary.simpleMessage("Environment"),
    "error_on_first_print": MessageLookupByLibrary.simpleMessage(
      "Error on first print",
    ),
    "event_type_invalid": MessageLookupByLibrary.simpleMessage(
      "Invalid event type",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expiration_date": MessageLookupByLibrary.simpleMessage("Expiration date"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter:"),
    "finish_return": MessageLookupByLibrary.simpleMessage("Finish return"),
    "friday_short": MessageLookupByLibrary.simpleMessage("Fri"),
    "general_printer_error_message": MessageLookupByLibrary.simpleMessage(
      "Cannot print document. Check printer configuration and device connection, then try again.",
    ),
    "generic_error_message": MessageLookupByLibrary.simpleMessage(
      "An error occurred. Try again or contact administrator.",
    ),
    "glass": MessageLookupByLibrary.simpleMessage("Glass"),
    "glass_return": MessageLookupByLibrary.simpleMessage(
      "Glass package return",
    ),
    "handing_over_driver": MessageLookupByLibrary.simpleMessage(
      "Hand over to driver",
    ),
    "i_confirm": MessageLookupByLibrary.simpleMessage("I confirm"),
    "i_confirm_finish": MessageLookupByLibrary.simpleMessage(
      "I confirm package return completion",
    ),
    "i_confirm_pickup": MessageLookupByLibrary.simpleMessage(
      "I confirm driver pickup of declared packages.",
    ),
    "if_you_see_this_screen": MessageLookupByLibrary.simpleMessage(
      "If you see this screen, it means the service is working correctly.",
    ),
    "illegible_voucher": MessageLookupByLibrary.simpleMessage(
      "Illegible voucher",
    ),
    "incorrect_bag_number": MessageLookupByLibrary.simpleMessage(
      "Wrong bag number",
    ),
    "incorrect_seal_number": MessageLookupByLibrary.simpleMessage(
      "Wrong seal number.",
    ),
    "incorrectly_rejected": MessageLookupByLibrary.simpleMessage(
      "Incorrectly rejected",
    ),
    "insights_request_sent": MessageLookupByLibrary.simpleMessage(
      "Request sent to Application Insights service",
    ),
    "invalid": MessageLookupByLibrary.simpleMessage("Invalid"),
    "invalid_credentials_info": MessageLookupByLibrary.simpleMessage(
      "Wrong login or password.\nPlease log in again.",
    ),
    "invalid_device_id": MessageLookupByLibrary.simpleMessage(
      "Invalid device ID",
    ),
    "invalid_package_type": MessageLookupByLibrary.simpleMessage(
      "Invalid package type",
    ),
    "invalid_seal_format": MessageLookupByLibrary.simpleMessage(
      "Invalid seal format",
    ),
    "is_not_deposit_package": MessageLookupByLibrary.simpleMessage(
      "is not a deposit package",
    ),
    "item_already_has_status": MessageLookupByLibrary.simpleMessage(
      "Item is assigned to another pickup",
    ),
    "item_incorrect_cc": MessageLookupByLibrary.simpleMessage(
      "Item with given ID is not assigned to your Counting Center",
    ),
    "item_incorrect_collection_point": MessageLookupByLibrary.simpleMessage(
      "Item with given ID is not assigned to your collection point",
    ),
    "item_not_closed": MessageLookupByLibrary.simpleMessage(
      "Item with given ID has not been closed",
    ),
    "item_not_found": MessageLookupByLibrary.simpleMessage(
      "Item with given ID not found",
    ),
    "item_not_released": MessageLookupByLibrary.simpleMessage(
      "Item with given ID has not been released",
    ),
    "items_empty": MessageLookupByLibrary.simpleMessage(
      "Items list cannot be empty",
    ),
    "label": MessageLookupByLibrary.simpleMessage("Label"),
    "label_and_seal_changed": MessageLookupByLibrary.simpleMessage(
      "Bag label and seal changed",
    ),
    "label_empty": MessageLookupByLibrary.simpleMessage(
      "Label number cannot be empty",
    ),
    "label_has_been_changed": MessageLookupByLibrary.simpleMessage(
      "Bag label has been changed",
    ),
    "label_number": MessageLookupByLibrary.simpleMessage("Label number"),
    "label_scan_success": MessageLookupByLibrary.simpleMessage(
      "Bag label scanned.",
    ),
    "last_added": MessageLookupByLibrary.simpleMessage("Last added"),
    "last_added_ean": MessageLookupByLibrary.simpleMessage("Last added EAN"),
    "last_package_not_assigned_and_removed": MessageLookupByLibrary.simpleMessage(
      "The last package was not assigned to an open bag and has been removed from the list. Please scan the package EAN again.",
    ),
    "last_package_removed_from_return": MessageLookupByLibrary.simpleMessage(
      "Last scanned package has been removed from returning packages list in current return.",
    ),
    "last_received": MessageLookupByLibrary.simpleMessage("Last received"),
    "list_of_added_bags": MessageLookupByLibrary.simpleMessage(
      "Added bags list",
    ),
    "list_of_bags_in_pickup": MessageLookupByLibrary.simpleMessage(
      "Bags in pickup list",
    ),
    "log_in": MessageLookupByLibrary.simpleMessage("Log in"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "logout_cancelled": MessageLookupByLibrary.simpleMessage(
      "Logout process cancelled",
    ),
    "lost_voucher": MessageLookupByLibrary.simpleMessage("Lost voucher"),
    "make_sure_codes_are_correct": MessageLookupByLibrary.simpleMessage(
      "Before confirming, check that codes are correctly assigned to label and seal numbers.",
    ),
    "manage_bags": MessageLookupByLibrary.simpleMessage("Manage bags"),
    "manage_boxes": MessageLookupByLibrary.simpleMessage(
      "Manage collection units",
    ),
    "manuals": MessageLookupByLibrary.simpleMessage("Manuals"),
    "mix": MessageLookupByLibrary.simpleMessage("Plastic / Can"),
    "monday_short": MessageLookupByLibrary.simpleMessage("Mon"),
    "new_bag": MessageLookupByLibrary.simpleMessage("New bag"),
    "new_bag_properly_opened": m2,
    "new_box_opened_correctly": MessageLookupByLibrary.simpleMessage(
      "New collection unit opened correctly",
    ),
    "next_stage_edit_impossible": MessageLookupByLibrary.simpleMessage(
      "Return cannot be edited after this stage",
    ),
    "no_access_contact_admin": MessageLookupByLibrary.simpleMessage(
      "You do not have permission to use this application.",
    ),
    "no_bags_in_current_pickup": MessageLookupByLibrary.simpleMessage(
      "No bags in current pickup.",
    ),
    "no_bags_to_display": MessageLookupByLibrary.simpleMessage(
      "No bags to display",
    ),
    "no_bags_were_selected": MessageLookupByLibrary.simpleMessage(
      "No bags were selected",
    ),
    "no_boxes_to_display": MessageLookupByLibrary.simpleMessage(
      "No collection units to display",
    ),
    "no_chosen_printer": MessageLookupByLibrary.simpleMessage(
      "No printer selected",
    ),
    "no_closed_bags": MessageLookupByLibrary.simpleMessage("No closed bags"),
    "no_internet": MessageLookupByLibrary.simpleMessage(
      "No connection - try again!",
    ),
    "no_open_bags": MessageLookupByLibrary.simpleMessage("No open bags"),
    "no_open_bags_of_this_type": MessageLookupByLibrary.simpleMessage(
      "No open bags of this type",
    ),
    "no_packages_in_open_bag": MessageLookupByLibrary.simpleMessage(
      "No packages in open bag",
    ),
    "no_packeges_in_return": MessageLookupByLibrary.simpleMessage(
      "No packages in open return.",
    ),
    "no_pickups": MessageLookupByLibrary.simpleMessage("No pickups"),
    "no_printer_configured": MessageLookupByLibrary.simpleMessage(
      "No printer found. Go to Settings and add device",
    ),
    "no_receivals": MessageLookupByLibrary.simpleMessage("No receivals"),
    "no_received_bags": MessageLookupByLibrary.simpleMessage(
      "No received bags.",
    ),
    "no_returns_selected_date": MessageLookupByLibrary.simpleMessage(
      "No returns for selected date.",
    ),
    "no_returns_today": MessageLookupByLibrary.simpleMessage(
      "No returns for today",
    ),
    "of_a_box": MessageLookupByLibrary.simpleMessage("collection unit"),
    "of_all_boxes": MessageLookupByLibrary.simpleMessage(
      "all collection units?",
    ),
    "ok_name": MessageLookupByLibrary.simpleMessage("OK Deposit Operator"),
    "open": MessageLookupByLibrary.simpleMessage("Open"),
    "open_bag": MessageLookupByLibrary.simpleMessage("Open bag"),
    "open_bags_has_been_fetched": MessageLookupByLibrary.simpleMessage(
      "Open bags have been fetched",
    ),
    "open_bags_list": MessageLookupByLibrary.simpleMessage("Open bags list"),
    "open_new_bag": MessageLookupByLibrary.simpleMessage("Open new bag"),
    "open_new_bag_CAN": MessageLookupByLibrary.simpleMessage(
      "Open new can bag",
    ),
    "open_new_bag_plastic": MessageLookupByLibrary.simpleMessage(
      "Open new plastic bag",
    ),
    "open_new_box": MessageLookupByLibrary.simpleMessage(
      "Open new collection unit",
    ),
    "or_enter_bag_number": MessageLookupByLibrary.simpleMessage(
      "or enter bag number",
    ),
    "or_enter_box_number": MessageLookupByLibrary.simpleMessage(
      "or enter collection unit number",
    ),
    "or_enter_ean": MessageLookupByLibrary.simpleMessage("or enter EAN number"),
    "or_enter_label_number": MessageLookupByLibrary.simpleMessage(
      "or enter label number",
    ),
    "or_enter_number": MessageLookupByLibrary.simpleMessage("or enter number"),
    "or_enter_seal_number": MessageLookupByLibrary.simpleMessage(
      "or enter seal number",
    ),
    "or_search_by_label": MessageLookupByLibrary.simpleMessage(
      "or search by label",
    ),
    "order_pickup": MessageLookupByLibrary.simpleMessage("Order pickup"),
    "package_receival": MessageLookupByLibrary.simpleMessage(
      "Package receival",
    ),
    "packages_in_bag": MessageLookupByLibrary.simpleMessage(
      "Packages in bag list",
    ),
    "packages_on_the_way": MessageLookupByLibrary.simpleMessage(
      "Packages on the way",
    ),
    "packages_receival_confirmation": MessageLookupByLibrary.simpleMessage(
      "Package receival confirmed",
    ),
    "packages_receival_confirmation_duplicates":
        MessageLookupByLibrary.simpleMessage(
          "Package receival confirmed. Note: Some bags in this receival were already scanned. System recognizes them as one operation and requires no additional action.",
        ),
    "packages_return": MessageLookupByLibrary.simpleMessage("Package return"),
    "partially_received": MessageLookupByLibrary.simpleMessage(
      "Partially received",
    ),
    "pet_quantity": MessageLookupByLibrary.simpleMessage(
      "Plastic bottles (pieces):",
    ),
    "pickup": MessageLookupByLibrary.simpleMessage("Pickup"),
    "pickup_confirmation_printed_again": MessageLookupByLibrary.simpleMessage(
      "Pickup confirmation document has been printed again.",
    ),
    "pickup_confirmation_subtitle": MessageLookupByLibrary.simpleMessage(
      "Two copies of pickup confirmation will be printed. Sign and give them to the driver!",
    ),
    "pickup_confirmed": MessageLookupByLibrary.simpleMessage(
      "Driver pickup confirmed",
    ),
    "pickup_confirmed_with_print_error": MessageLookupByLibrary.simpleMessage(
      "Driver pickup confirmed.\nPrint error occurred. Try again by going to pickup details",
    ),
    "pickup_not_found": MessageLookupByLibrary.simpleMessage(
      "Pickup with given ID not found",
    ),
    "pickup_summary": MessageLookupByLibrary.simpleMessage("Pickup summary"),
    "pickups": MessageLookupByLibrary.simpleMessage("Pickups"),
    "pickups_overview": MessageLookupByLibrary.simpleMessage(
      "Pickups overview",
    ),
    "pieces": MessageLookupByLibrary.simpleMessage("Pieces"),
    "planned_receival": MessageLookupByLibrary.simpleMessage(
      "Planned receivals",
    ),
    "plastic": MessageLookupByLibrary.simpleMessage("Plastic"),
    "pln_return_sum": MessageLookupByLibrary.simpleMessage("Return sum PLN"),
    "pln_sum": MessageLookupByLibrary.simpleMessage("Sum PLN"),
    "print_pickup_confirmation": MessageLookupByLibrary.simpleMessage(
      "Print pickup confirmation",
    ),
    "print_voucher": MessageLookupByLibrary.simpleMessage("Print voucher"),
    "print_voucher_for_client": MessageLookupByLibrary.simpleMessage(
      "Print voucher for client",
    ),
    "printer_bluetooth_address_not_valid_error_message":
        MessageLookupByLibrary.simpleMessage(
          "Printer configuration error - make sure selected printer is correctly configured.",
        ),
    "printer_bluetooth_not_turned_on_error_message":
        MessageLookupByLibrary.simpleMessage(
          "Print error: no printer connection. Check if Bluetooth is on and try again.",
        ),
    "printer_config": MessageLookupByLibrary.simpleMessage(
      "Printer configuration",
    ),
    "printer_not_turned_on_error_message": MessageLookupByLibrary.simpleMessage(
      "Print error: make sure printer is turned on and properly connected.",
    ),
    "printer_was_chosen": m3,
    "properly_opened": MessageLookupByLibrary.simpleMessage("opened correctly"),
    "quantity_less_or_equal_zero": MessageLookupByLibrary.simpleMessage(
      "Quantity must be greater than zero",
    ),
    "reason_for_voucher_print_cancelation":
        MessageLookupByLibrary.simpleMessage(
          "Choose reason to cancel voucher print:",
        ),
    "reason_invalid": MessageLookupByLibrary.simpleMessage(
      "Invalid seal/label change reason",
    ),
    "receival": MessageLookupByLibrary.simpleMessage("Receival"),
    "receival_summary": MessageLookupByLibrary.simpleMessage(
      "Receival summary",
    ),
    "receival_tally": MessageLookupByLibrary.simpleMessage("Receival tally"),
    "received_in_cc": MessageLookupByLibrary.simpleMessage("Received in CC"),
    "refresh_remote_config": MessageLookupByLibrary.simpleMessage(
      "Refresh remote configuration",
    ),
    "reject": MessageLookupByLibrary.simpleMessage("Reject"),
    "reject_return": MessageLookupByLibrary.simpleMessage("Reject return"),
    "released": MessageLookupByLibrary.simpleMessage("Released to driver"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "removed_last_printer": MessageLookupByLibrary.simpleMessage(
      "Removed last added printer",
    ),
    "reprint_voucher_confirmation": MessageLookupByLibrary.simpleMessage(
      "Voucher has been printed",
    ),
    "return_closed_print_voucher": MessageLookupByLibrary.simpleMessage(
      "Return has been closed. Print voucher.",
    ),
    "return_closed_show_voucher": MessageLookupByLibrary.simpleMessage(
      "Return has been closed. Show voucher.",
    ),
    "return_deposing_packages": MessageLookupByLibrary.simpleMessage(
      "Return deposit packages",
    ),
    "return_finish_confirmation": MessageLookupByLibrary.simpleMessage(
      "Package return completion confirmation",
    ),
    "return_glass_bottles": MessageLookupByLibrary.simpleMessage(
      "Package return: Glass",
    ),
    "return_glass_bottles_title": MessageLookupByLibrary.simpleMessage(
      "Glass package return",
    ),
    "return_plastics_cans": MessageLookupByLibrary.simpleMessage(
      "Package return: Plastic, Can",
    ),
    "return_summary": MessageLookupByLibrary.simpleMessage("Return summary"),
    "return_text": MessageLookupByLibrary.simpleMessage("Return"),
    "returning_packages_list": MessageLookupByLibrary.simpleMessage(
      "Returning packages list",
    ),
    "returns_archive": MessageLookupByLibrary.simpleMessage("Returns archive"),
    "saturday_short": MessageLookupByLibrary.simpleMessage("Sat"),
    "scan_bag_code": MessageLookupByLibrary.simpleMessage("Scan bag code"),
    "scan_bag_seal_code": MessageLookupByLibrary.simpleMessage(
      "Scan bag seal code",
    ),
    "scan_bag_seal_code_pickup": MessageLookupByLibrary.simpleMessage(
      "Scan bag seal code and add bag to pickup",
    ),
    "scan_box_label_or_pick_from_list": MessageLookupByLibrary.simpleMessage(
      "Scan collection unit code or select from list",
    ),
    "scan_new_bag": MessageLookupByLibrary.simpleMessage("Scan new bag code"),
    "scan_new_bag_label_code": MessageLookupByLibrary.simpleMessage(
      "Scan new bag label code",
    ),
    "scan_new_box": MessageLookupByLibrary.simpleMessage(
      "Scan new collection unit code",
    ),
    "scan_new_printer_code": MessageLookupByLibrary.simpleMessage(
      "Scan new printer code",
    ),
    "scan_new_seal": MessageLookupByLibrary.simpleMessage("Scan new seal"),
    "scan_new_seal_code": MessageLookupByLibrary.simpleMessage(
      "Scan new seal code",
    ),
    "scan_or_pick_bag_number": MessageLookupByLibrary.simpleMessage(
      "Scan bag code or select from list",
    ),
    "scan_package_ean": MessageLookupByLibrary.simpleMessage(
      "Scan package EAN",
    ),
    "scan_seal": MessageLookupByLibrary.simpleMessage("Scan seal code"),
    "scan_seal_and_add_bag_to_pickup": MessageLookupByLibrary.simpleMessage(
      "Scan bag seal code \nand add bag to pickup",
    ),
    "scan_seal_and_add_bag_to_receival": MessageLookupByLibrary.simpleMessage(
      "Scan bag seal code \nand add bag to receival",
    ),
    "scan_seal_or_pick_from_list": MessageLookupByLibrary.simpleMessage(
      "Scan seal code or select from list",
    ),
    "scanned_package_must_be_assigned_to_bag":
        MessageLookupByLibrary.simpleMessage(
          "Scanned package must be assigned to a bag.",
        ),
    "scanned_package_of_not_allowed_type": MessageLookupByLibrary.simpleMessage(
      "Scanned package type is not supported at your collection point.",
    ),
    "scanned_package_requires_bag_change": MessageLookupByLibrary.simpleMessage(
      "Scanned package requires bag change.",
    ),
    "seal": MessageLookupByLibrary.simpleMessage("Seal"),
    "seal_added_successfully": MessageLookupByLibrary.simpleMessage(
      "Bag has been sealed.",
    ),
    "seal_already_exists": MessageLookupByLibrary.simpleMessage(
      "Seal with this number already exists",
    ),
    "seal_another_bag": MessageLookupByLibrary.simpleMessage(
      "Seal another bag",
    ),
    "seal_bag": MessageLookupByLibrary.simpleMessage("Seal bag"),
    "seal_changed_succesfully": MessageLookupByLibrary.simpleMessage(
      "Seal has been changed successfully.",
    ),
    "seal_empty": MessageLookupByLibrary.simpleMessage(
      "Seal number cannot be empty",
    ),
    "seal_number": MessageLookupByLibrary.simpleMessage("Seal number"),
    "seal_scan_success": MessageLookupByLibrary.simpleMessage(
      "Seal code scanned.",
    ),
    "seal_was_added_successfully": MessageLookupByLibrary.simpleMessage(
      "Seal has been added correctly.",
    ),
    "sealed": MessageLookupByLibrary.simpleMessage("Sealed"),
    "sealed_bag": MessageLookupByLibrary.simpleMessage("Sealed bag"),
    "sealed_bags_list": MessageLookupByLibrary.simpleMessage(
      "Sealed bags list",
    ),
    "security_deposit_voucher": MessageLookupByLibrary.simpleMessage(
      "Deposit voucher",
    ),
    "select_all": MessageLookupByLibrary.simpleMessage("Select all"),
    "selected_bags": MessageLookupByLibrary.simpleMessage("Selected bags"),
    "selected_day": m4,
    "sent_bags": MessageLookupByLibrary.simpleMessage("Sent bags"),
    "server_error": MessageLookupByLibrary.simpleMessage(
      "Server error. Please try again later.",
    ),
    "session_expired": MessageLookupByLibrary.simpleMessage(
      "Session expired, please log in again",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "show_voucher": MessageLookupByLibrary.simpleMessage("Show voucher"),
    "submit_boxes_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Submit collection units for pickup",
    ),
    "submitted_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Submitted for pickup",
    ),
    "summary": MessageLookupByLibrary.simpleMessage("Summary"),
    "sunday_short": MessageLookupByLibrary.simpleMessage("Sun"),
    "technical_issue": MessageLookupByLibrary.simpleMessage("Technical issue"),
    "terms_and_condition_paragraph_1": MessageLookupByLibrary.simpleMessage(
      "I. Introduction: Our commitment to protecting our users\' data",
    ),
    "terms_and_conditions_part_1": MessageLookupByLibrary.simpleMessage(
      "In today\'s digital world, where data has become a key resource, OK OPERATOR KAUCYJNY S.A. recognizes personal data protection as a fundamental element of our operations. We are deeply convinced that the trust of people who use our services and our contractors is not only a privilege, but also an obligation that we treat with the utmost seriousness.",
    ),
    "terms_and_conditions_part_2": MessageLookupByLibrary.simpleMessage(
      "Our company, operating in the deposit industry, realizes that effective personal data protection is crucial for maintaining the integrity of our business processes, building long-term relationships with partners, and ensuring compliance with applicable laws. Therefore, personal data protection is not only a legal obligation for us, but is an integral part of our organizational culture and business ethics.",
    ),
    "terms_and_conditions_part_3": MessageLookupByLibrary.simpleMessage(
      "At OK OPERATOR KAUCYJNY S.A. we believe that transparency in personal data processing is the foundation of trust in business relationships. Therefore, we make every effort to provide our partners and customers with full transparency regarding how we collect, process and protect their personal data. Our privacy policy is an expression of this commitment - it is a comprehensive guide to our data protection practices.",
    ),
    "terms_and_conditions_part_4": MessageLookupByLibrary.simpleMessage(
      "We invest significant resources in the most modern technological and organizational solutions to guarantee the highest level of security for the data entrusted to us. We regularly conduct audits and updates of our systems to meet the constantly evolving threats in cyberspace. At the same time, we provide ongoing training to our employees so that they are fully aware of the importance of personal data protection and know the best practices in this area.",
    ),
    "terms_and_conditions_part_5": MessageLookupByLibrary.simpleMessage(
      "We understand that in a dynamic business environment, effective information exchange is crucial for success. Therefore, while caring for data protection, we strive to simultaneously ensure business process fluidity for our partners and customers. Our privacy policy is designed to enable effective cooperation while maintaining the highest data protection standards.",
    ),
    "terms_and_conditions_part_6": MessageLookupByLibrary.simpleMessage(
      "At OK OPERATOR KAUCYJNY S.A. we are convinced that responsible personal data management is not only a legal obligation, but also a key factor in building trust and loyalty of our business partners and customers. Therefore, we commit to continuously improving our data protection practices, adapting to changing legal and technological realities, and maintaining open dialogue with our stakeholders on data privacy issues.",
    ),
    "terms_and_conditions_part_7": MessageLookupByLibrary.simpleMessage(
      "We invite you to read our detailed privacy policy, which reflects our commitment to protecting your personal data. We are convinced that through these actions we build not only secure, but also lasting business relationships, based on mutual trust and respect for privacy.",
    ),
    "terms_and_conditions_title": MessageLookupByLibrary.simpleMessage(
      "OK mobile app terms and conditions",
    ),
    "test_application_insights": MessageLookupByLibrary.simpleMessage(
      "Test Application Insights",
    ),
    "thursday_short": MessageLookupByLibrary.simpleMessage("Thu"),
    "token_not_provided": MessageLookupByLibrary.simpleMessage(
      "Token not provided",
    ),
    "torn_bag": MessageLookupByLibrary.simpleMessage("Torn bag"),
    "torn_box": MessageLookupByLibrary.simpleMessage("Torn collection unit"),
    "total_quantity": MessageLookupByLibrary.simpleMessage("Total:"),
    "tuesday_short": MessageLookupByLibrary.simpleMessage("Tue"),
    "type_invalid": MessageLookupByLibrary.simpleMessage("Invalid bag type"),
    "type_not_found": MessageLookupByLibrary.simpleMessage(
      "Bag type not found",
    ),
    "unknown_ean_code": MessageLookupByLibrary.simpleMessage(
      "Unknown EAN code",
    ),
    "unreadable_label": MessageLookupByLibrary.simpleMessage(
      "Unreadable label",
    ),
    "unreadable_seal": MessageLookupByLibrary.simpleMessage("Unreadable seal"),
    "user_not_authorized": MessageLookupByLibrary.simpleMessage(
      "You are not authorized for this action",
    ),
    "voucher_generation_date": MessageLookupByLibrary.simpleMessage(
      "Voucher generation date",
    ),
    "voucher_issuance": MessageLookupByLibrary.simpleMessage(
      "Voucher issuance",
    ),
    "voucher_printed_for_client": MessageLookupByLibrary.simpleMessage(
      "Voucher has been printed",
    ),
    "wednesday_short": MessageLookupByLibrary.simpleMessage("Wed"),
    "welcome_to_system": MessageLookupByLibrary.simpleMessage(
      "Welcome to system",
    ),
    "wrong_device_to_cc": MessageLookupByLibrary.simpleMessage(
      "Wrong device assignment to counting center.",
    ),
    "wrong_device_to_collection_point": MessageLookupByLibrary.simpleMessage(
      "Wrong device assignment to collection point.",
    ),
    "wrong_device_to_retail_chain": MessageLookupByLibrary.simpleMessage(
      "Wrong device assignment to retail chain.",
    ),
    "wrong_package_type": MessageLookupByLibrary.simpleMessage(
      "Scanned item is not a package",
    ),
    "wrong_user_configuration": MessageLookupByLibrary.simpleMessage(
      "User not configured correctly.",
    ),
    "wrong_user_to_cc": MessageLookupByLibrary.simpleMessage(
      "Wrong user assignment to counting center.",
    ),
    "wrong_user_to_collection_point": MessageLookupByLibrary.simpleMessage(
      "Wrong user assignment to collection point.",
    ),
    "wrong_user_to_retail_chain": MessageLookupByLibrary.simpleMessage(
      "Wrong user assignment to retail chain.",
    ),
  };
}
