// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pl locale. All the
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
  String get localeName => 'pl';

  static String m0(id) => "Wybrano worek ${id}.";

  static String m1(id, type) => "Wybrano worek ${type} ${id}.";

  static String m2(id) => "Nowy worek ${id} otwarty prawidłowo.";

  static String m3(mac_address) => "Wybrano drukarkę ${mac_address}";

  static String m4(day) => "Wybrano dzień: ${day}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept_terms": MessageLookupByLibrary.simpleMessage(
      "Akceptacja regulaminu",
    ),
    "accept_terms_and_conditions": MessageLookupByLibrary.simpleMessage(
      "Akceptuję regulamin",
    ),
    "actual_return_full_packages_list": MessageLookupByLibrary.simpleMessage(
      "Pełna lista opakowań w aktualnym zwrocie",
    ),
    "add_bags_to_box": MessageLookupByLibrary.simpleMessage(
      "Dodaj worki do jednostki zbiorczej",
    ),
    "add_printer_to_start_pickup": MessageLookupByLibrary.simpleMessage(
      "Dodaj drukarkę aby rozpocząć wydanie",
    ),
    "add_printer_to_start_return": MessageLookupByLibrary.simpleMessage(
      "Dodaj drukarkę aby rozpocząć zwrot opakowań kaucyjnych",
    ),
    "add_seal": MessageLookupByLibrary.simpleMessage("Dodaj plombę"),
    "add_to_box": MessageLookupByLibrary.simpleMessage(
      "Dodaj do jednostki zbiorczej",
    ),
    "added_seal": MessageLookupByLibrary.simpleMessage("Dodano plombę"),
    "admin": MessageLookupByLibrary.simpleMessage("Administracja"),
    "all_bags_added_to_box": MessageLookupByLibrary.simpleMessage(
      "Worki zostały dodane do jednostki zbiorczej",
    ),
    "all_boxes_closed": MessageLookupByLibrary.simpleMessage(
      "Wszystkie jednostki zbiorcze zostały zamknięte",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Powrót"),
    "bag": MessageLookupByLibrary.simpleMessage("Worek"),
    "bag_already_added_to_box": MessageLookupByLibrary.simpleMessage(
      "Ten worek jest już przypisany do jednostki zbiorczej",
    ),
    "bag_already_added_to_pickup": MessageLookupByLibrary.simpleMessage(
      "Worek o tym numerze został już dodany do wydania.",
    ),
    "bag_already_added_to_receival": MessageLookupByLibrary.simpleMessage(
      "Worek o tym numerze został już dodany do przyjęcia.",
    ),
    "bag_already_closed": MessageLookupByLibrary.simpleMessage(
      "Worek jest już zamknięty.",
    ),
    "bag_already_received": MessageLookupByLibrary.simpleMessage(
      "Worek został już przyjęty",
    ),
    "bag_choice": MessageLookupByLibrary.simpleMessage("Wybór worka"),
    "bag_chosen": MessageLookupByLibrary.simpleMessage("Wybrano worek"),
    "bag_closed_choose_open_instead": MessageLookupByLibrary.simpleMessage(
      "Wybrany worek jest zamknięty, zeskanuj etykietę otwartego worka.",
    ),
    "bag_contains_open_return_packages": MessageLookupByLibrary.simpleMessage(
      "W worku znajdują się opakowania z otwartego zwrotu. Zamknij zwrot",
    ),
    "bag_correctly_chosen": MessageLookupByLibrary.simpleMessage(
      "Worek wybrany prawidłowo.",
    ),
    "bag_correctly_opened": MessageLookupByLibrary.simpleMessage(
      "Worek otwarty prawidłowo",
    ),
    "bag_empty": MessageLookupByLibrary.simpleMessage(
      "Numer worka nie może być pusty",
    ),
    "bag_incorrect_collection_point": MessageLookupByLibrary.simpleMessage(
      "Worek o podanym id nie jest przypisany do Twojego punktu zbiórki",
    ),
    "bag_incorrect_item_for_bag": MessageLookupByLibrary.simpleMessage(
      "Opakowanie ma przypisany inny typ niż worek",
    ),
    "bag_is_open": MessageLookupByLibrary.simpleMessage("Worek jest otwarty"),
    "bag_not_assigned_to_collection_point":
        MessageLookupByLibrary.simpleMessage(
          "Ten worek nie jest przypisany do Twojego punktu zbiórki",
        ),
    "bag_not_closed": MessageLookupByLibrary.simpleMessage(
      "Worek nie może zostać dodany do jednostki zbiorczej bo nie jest zamknięty.",
    ),
    "bag_not_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono worka o podanym kodzie",
    ),
    "bag_not_released": MessageLookupByLibrary.simpleMessage(
      "Worek nie został wydany",
    ),
    "bag_selected_for_closing": MessageLookupByLibrary.simpleMessage(
      "Wybrano worek do zaplombowania.",
    ),
    "bag_selected_for_label_change": MessageLookupByLibrary.simpleMessage(
      "Wybrano worek do zmiany etykiety.",
    ),
    "bag_selected_for_seal_change": MessageLookupByLibrary.simpleMessage(
      "Wybrano worek do zmiany plomby.",
    ),
    "bag_summary": MessageLookupByLibrary.simpleMessage("Podsumowanie worka"),
    "bag_was_added_to_box": MessageLookupByLibrary.simpleMessage(
      "Worek został dodany do jednostki zbiorczej",
    ),
    "bag_was_chosen": m0,
    "bag_was_chosen_with_type": m1,
    "bag_was_closed": MessageLookupByLibrary.simpleMessage(
      "Worek został zamknięty.",
    ),
    "bag_was_removed_from_box": MessageLookupByLibrary.simpleMessage(
      "Worek został usunięty z jednostki zbiorczej",
    ),
    "bags": MessageLookupByLibrary.simpleMessage("Worki"),
    "bags_management": MessageLookupByLibrary.simpleMessage(
      "Zarządzanie workami",
    ),
    "before_print": MessageLookupByLibrary.simpleMessage("Przed wydrukiem"),
    "box": MessageLookupByLibrary.simpleMessage("Jednostka zbiorcza"),
    "box_already_closed": MessageLookupByLibrary.simpleMessage(
      "Jednostka zbiorcza została już wcześniej zamknięta",
    ),
    "box_correctly_opened": MessageLookupByLibrary.simpleMessage(
      "Jednostka zbiorcza otwarta prawidłowo",
    ),
    "box_empty": MessageLookupByLibrary.simpleMessage(
      "Numer jednostki zbiorczej nie może być pusty",
    ),
    "box_ids_empty": MessageLookupByLibrary.simpleMessage(
      "Lista id jednostek zbiorczych nie może być pusta",
    ),
    "box_not_assigned_to_collection_point":
        MessageLookupByLibrary.simpleMessage(
          "Ta jednostka zbiorcza nie jest przypisana do Twojego punktu zbiórki",
        ),
    "box_not_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono jednostki zbiorczej",
    ),
    "box_summary": MessageLookupByLibrary.simpleMessage(
      "Podsumowanie jednostki zbiorczej",
    ),
    "box_was_closed": MessageLookupByLibrary.simpleMessage(
      "Jednostka zbiorcza została zamknięta",
    ),
    "boxes": MessageLookupByLibrary.simpleMessage("Jednostki zbiorcze"),
    "camera_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Odmowa dostępu do kamery",
    ),
    "can": MessageLookupByLibrary.simpleMessage("Puszka"),
    "can_quantity": MessageLookupByLibrary.simpleMessage("Puszki (sztuki):"),
    "cancel_voucher_print": MessageLookupByLibrary.simpleMessage(
      "Zrezygnuj z wydruku bonu",
    ),
    "canceled": MessageLookupByLibrary.simpleMessage("Anulowany"),
    "cancelled_print": MessageLookupByLibrary.simpleMessage("Anulowany wydruk"),
    "cc_empty": MessageLookupByLibrary.simpleMessage(
      "Brak numeru Counting Center",
    ),
    "cc_not_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono Counting Center o podanym id",
    ),
    "change_bag": MessageLookupByLibrary.simpleMessage("Zmień worek"),
    "change_box_label": MessageLookupByLibrary.simpleMessage(
      "Zmień etykietę jednostki zbiorczej",
    ),
    "change_label": MessageLookupByLibrary.simpleMessage("Zmień etykietę"),
    "change_label_or_bag": MessageLookupByLibrary.simpleMessage(
      "Zmień etykietę/worek",
    ),
    "change_seal": MessageLookupByLibrary.simpleMessage("Zmień plombę"),
    "change_seal_after_label_change": MessageLookupByLibrary.simpleMessage(
      "W przypadku zaplombowanego worka konieczna jest wymiana etykiety oraz plomby.",
    ),
    "choose_open_bag": MessageLookupByLibrary.simpleMessage(
      "Wybierz otwarty worek",
    ),
    "choose_open_bag_CAN": MessageLookupByLibrary.simpleMessage(
      "Wybierz otwarty worek Puszka",
    ),
    "choose_open_bag_plastic": MessageLookupByLibrary.simpleMessage(
      "Wybierz otwarty worek Plastik",
    ),
    "choose_open_box": MessageLookupByLibrary.simpleMessage(
      "Wybierz otwartą jednostkę zbiorczą",
    ),
    "choose_reason_for_label_change": MessageLookupByLibrary.simpleMessage(
      "Wybierz powód zmiany etykiety",
    ),
    "choose_reason_for_label_or_bag_change":
        MessageLookupByLibrary.simpleMessage(
          "Wybierz powód zmiany etykiety / worka:",
        ),
    "choose_reason_for_seal_change": MessageLookupByLibrary.simpleMessage(
      "Wybierz powód zmiany plomby:",
    ),
    "choose_voucher_print_reason": MessageLookupByLibrary.simpleMessage(
      "Wybierz powód wydruku bonu:",
    ),
    "choose_voucher_reprint_reason": MessageLookupByLibrary.simpleMessage(
      "Wybierz powód ponownego wydruku bonu:",
    ),
    "chosen_bag": MessageLookupByLibrary.simpleMessage("Wybrany worek"),
    "chosen_bag_for_packages": MessageLookupByLibrary.simpleMessage(
      "Wybrany worek dla opakowań",
    ),
    "chosen_printer": MessageLookupByLibrary.simpleMessage("Wybrana drukarka"),
    "client_resignation": MessageLookupByLibrary.simpleMessage(
      "Rezygnacja klienta",
    ),
    "close_and_seal": MessageLookupByLibrary.simpleMessage(
      "Zamknij i zaplombuj worek",
    ),
    "close_bag": MessageLookupByLibrary.simpleMessage("Zamknij worek"),
    "close_box": MessageLookupByLibrary.simpleMessage(
      "Zamknij jednostkę zbiorczą",
    ),
    "close_boxes": MessageLookupByLibrary.simpleMessage(
      "Zamknij jednostki zbiorcze",
    ),
    "closed": MessageLookupByLibrary.simpleMessage("Zamknięty"),
    "closed_bag": MessageLookupByLibrary.simpleMessage("Zamknięty worek"),
    "closed_bags": MessageLookupByLibrary.simpleMessage("Zamknięte worki"),
    "closed_bags_list": MessageLookupByLibrary.simpleMessage(
      "Lista worków zamkniętych",
    ),
    "closed_returns": MessageLookupByLibrary.simpleMessage("Zamknięte zwroty"),
    "closed_returns_archive": MessageLookupByLibrary.simpleMessage(
      "Archiwum zamkniętych zwrotów",
    ),
    "closed_returns_list": MessageLookupByLibrary.simpleMessage(
      "Lista zamkniętych zwrotów",
    ),
    "collected_packages": MessageLookupByLibrary.simpleMessage(
      "Przyjęte opakowania",
    ),
    "collection_point_id_empty": MessageLookupByLibrary.simpleMessage(
      "ID punktu zbiórki nie może być puste",
    ),
    "collection_point_not_exist": MessageLookupByLibrary.simpleMessage(
      "Punkt zbiórki o podanym ID nie istnieje",
    ),
    "comment_empty": MessageLookupByLibrary.simpleMessage(
      "Komentarz nie może być pusty",
    ),
    "configure_printer": MessageLookupByLibrary.simpleMessage(
      "Skonfiguruj drukarkę",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Potwierdź"),
    "confirm_and_print_document": MessageLookupByLibrary.simpleMessage(
      "Potwierdź i drukuj dokument",
    ),
    "confirm_pickup": MessageLookupByLibrary.simpleMessage("Potwierdź wydanie"),
    "confirm_receival": MessageLookupByLibrary.simpleMessage(
      "Potwierdź przyjęcie",
    ),
    "confirm_voucher_print": MessageLookupByLibrary.simpleMessage(
      "Potwierdzam wydruk bonu dla zwrotu",
    ),
    "contact_admin": MessageLookupByLibrary.simpleMessage(
      "Aby naprawić problem skontaktuj się z Administratorem.",
    ),
    "correct": MessageLookupByLibrary.simpleMessage("Poprawny"),
    "correct_print": MessageLookupByLibrary.simpleMessage("Poprawny wydruk"),
    "current_receival": MessageLookupByLibrary.simpleMessage(
      "Aktualne przyjęcie",
    ),
    "current_release": MessageLookupByLibrary.simpleMessage("Aktualne wydanie"),
    "current_return": MessageLookupByLibrary.simpleMessage("Aktualny zwrot"),
    "damaged_bag": MessageLookupByLibrary.simpleMessage("Zniszczony worek"),
    "damaged_label": MessageLookupByLibrary.simpleMessage(
      "Zniszczona etykieta",
    ),
    "damaged_seal": MessageLookupByLibrary.simpleMessage("Uszkodzona plomba"),
    "days": MessageLookupByLibrary.simpleMessage("dni"),
    "declare_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Zgłoś do odbioru",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Szczegóły"),
    "device_id_empty": MessageLookupByLibrary.simpleMessage(
      "ID urządzenia nie może być puste",
    ),
    "device_id_too_long": MessageLookupByLibrary.simpleMessage(
      "Podano zbyt długie ID urządzenia",
    ),
    "device_not_configured": MessageLookupByLibrary.simpleMessage(
      "Urządzenie nie zostało poprawnie skonfigurowane.",
    ),
    "different_issue": MessageLookupByLibrary.simpleMessage("Inny problem"),
    "different_reason": MessageLookupByLibrary.simpleMessage("Inny powód"),
    "do_you_really_want_to_close": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz potwierdzić zamknięcie",
    ),
    "duplicated_label_error": MessageLookupByLibrary.simpleMessage(
      "Worek o takim numerze już istnieje w systemie - zmień etykietę.",
    ),
    "ean": MessageLookupByLibrary.simpleMessage("EAN"),
    "ean_empty": MessageLookupByLibrary.simpleMessage("EAN nie może być pusty"),
    "ean_not_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono opakowania o podanym EAN",
    ),
    "empty": MessageLookupByLibrary.simpleMessage("PUSTY"),
    "empty_bag_cannot_be_closed": MessageLookupByLibrary.simpleMessage(
      "Brak możliwości zamknięcia pustego worka",
    ),
    "enter_bag_number": MessageLookupByLibrary.simpleMessage(
      "Podaj numer worka",
    ),
    "environment": MessageLookupByLibrary.simpleMessage("Środowisko"),
    "error_on_first_print": MessageLookupByLibrary.simpleMessage(
      "Błąd przy pierwszym wydruku",
    ),
    "event_type_invalid": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy typ zdarzenia",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("Wyjdź"),
    "expiration_date": MessageLookupByLibrary.simpleMessage("Termin ważności"),
    "filter": MessageLookupByLibrary.simpleMessage("Filtruj:"),
    "finish_return": MessageLookupByLibrary.simpleMessage("Zakończ zwrot"),
    "friday_short": MessageLookupByLibrary.simpleMessage("Pt"),
    "general_printer_error_message": MessageLookupByLibrary.simpleMessage(
      "Nie można wydrukować dokumentu. Sprawdź konfigurację drukarki oraz połączenie z urządzeniem, a następnie spróbuj ponownie.",
    ),
    "generic_error_message": MessageLookupByLibrary.simpleMessage(
      "Wystąpił błąd. Spróbuj ponownie albo skontaktuj się z administratorem.",
    ),
    "glass": MessageLookupByLibrary.simpleMessage("Szkło"),
    "glass_return": MessageLookupByLibrary.simpleMessage(
      "Zwrot opakowań szklanych",
    ),
    "handing_over_driver": MessageLookupByLibrary.simpleMessage(
      "Wydanie kierowcy",
    ),
    "i_confirm": MessageLookupByLibrary.simpleMessage("Potwierdzam"),
    "i_confirm_finish": MessageLookupByLibrary.simpleMessage(
      "Potwierdzam zakończenie zwrotu opakowań",
    ),
    "i_confirm_pickup": MessageLookupByLibrary.simpleMessage(
      "Potwierdzam wydanie kierowcy zadeklarowanych opakowań.",
    ),
    "if_you_see_this_screen": MessageLookupByLibrary.simpleMessage(
      "Jeśli widzisz ten ekran, to znaczy że usługa działa poprawnie.",
    ),
    "illegible_voucher": MessageLookupByLibrary.simpleMessage(
      "Nieczytelny bon",
    ),
    "incorrect_bag_number": MessageLookupByLibrary.simpleMessage(
      "Błędny numer worka",
    ),
    "incorrect_seal_number": MessageLookupByLibrary.simpleMessage(
      "Błędny numer plomby.",
    ),
    "incorrectly_rejected": MessageLookupByLibrary.simpleMessage(
      "Odrzucony błędnie",
    ),
    "insights_request_sent": MessageLookupByLibrary.simpleMessage(
      "Wysłano zapytanie do serwisu Application Insights",
    ),
    "invalid": MessageLookupByLibrary.simpleMessage("Nieprawidłowy"),
    "invalid_credentials_info": MessageLookupByLibrary.simpleMessage(
      "Podano błędny login lub hasło.\nZaloguj się ponownie.",
    ),
    "invalid_device_id": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowe ID urządzenia",
    ),
    "invalid_package_type": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy typ opakowania",
    ),
    "invalid_seal_format": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy format plomby",
    ),
    "is_not_deposit_package": MessageLookupByLibrary.simpleMessage(
      "nie jest opakowaniem kaucyjnym",
    ),
    "item_already_has_status": MessageLookupByLibrary.simpleMessage(
      "Podany obiekt jest przypisany do innego wydania",
    ),
    "item_incorrect_cc": MessageLookupByLibrary.simpleMessage(
      "Obiekt o podanym id nie jest przypisany do Twojego Counting Center",
    ),
    "item_incorrect_collection_point": MessageLookupByLibrary.simpleMessage(
      "Obiekt o podanym id nie jest przypisany do Twojego punktu zbiórki",
    ),
    "item_not_closed": MessageLookupByLibrary.simpleMessage(
      "Obiekt o podanym id nie został zamknięty",
    ),
    "item_not_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono obiektu o podanym id",
    ),
    "item_not_released": MessageLookupByLibrary.simpleMessage(
      "Obiekt o podanym id nie został wydany",
    ),
    "items_empty": MessageLookupByLibrary.simpleMessage(
      "Lista obiektów nie może być pusta",
    ),
    "label": MessageLookupByLibrary.simpleMessage("Etykieta"),
    "label_and_seal_changed": MessageLookupByLibrary.simpleMessage(
      "Zmieniono etykietę i plombę worka",
    ),
    "label_empty": MessageLookupByLibrary.simpleMessage(
      "Numer etykiety nie może być pusty",
    ),
    "label_has_been_changed": MessageLookupByLibrary.simpleMessage(
      "Zmieniono etykietę worka",
    ),
    "label_number": MessageLookupByLibrary.simpleMessage("Numer etykiety"),
    "label_scan_success": MessageLookupByLibrary.simpleMessage(
      "Zeskanowano etykietę worka.",
    ),
    "last_added": MessageLookupByLibrary.simpleMessage("Ostatni dodany"),
    "last_added_ean": MessageLookupByLibrary.simpleMessage(
      "Ostatni dodany EAN",
    ),
    "last_package_not_assigned_and_removed": MessageLookupByLibrary.simpleMessage(
      "Ostatniego opakowania nie przypisano do otwartego worka i usunięto je z listy. Zeskanuj ponownie EAN opakowania.",
    ),
    "last_package_removed_from_return": MessageLookupByLibrary.simpleMessage(
      "Ostatnie zeskanowane opakowanie zostało usunięte z listy zwracanych opakowań w aktualnym zwrocie.",
    ),
    "last_received": MessageLookupByLibrary.simpleMessage("Ostatnio przyjęty"),
    "list_of_added_bags": MessageLookupByLibrary.simpleMessage(
      "Lista dodanych worków",
    ),
    "list_of_bags_in_pickup": MessageLookupByLibrary.simpleMessage(
      "Lista worków w wydaniu",
    ),
    "log_in": MessageLookupByLibrary.simpleMessage("Zaloguj się"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "logout": MessageLookupByLibrary.simpleMessage("Wyloguj się"),
    "logout_cancelled": MessageLookupByLibrary.simpleMessage(
      "Przerwano proces wylogowania",
    ),
    "lost_voucher": MessageLookupByLibrary.simpleMessage("Zgubiony bon"),
    "make_sure_codes_are_correct": MessageLookupByLibrary.simpleMessage(
      "Przed potwierdzeniem sprawdź czy kody są prawidłowo przypisane do numeru etykiety i plomby.",
    ),
    "manage_bags": MessageLookupByLibrary.simpleMessage("Zarządzanie workami"),
    "manage_boxes": MessageLookupByLibrary.simpleMessage(
      "Zarządzanie jednostkami zbiorczymi",
    ),
    "manuals": MessageLookupByLibrary.simpleMessage("Instrukcje"),
    "mix": MessageLookupByLibrary.simpleMessage("Plastik / Puszka"),
    "monday_short": MessageLookupByLibrary.simpleMessage("Pn"),
    "new_bag": MessageLookupByLibrary.simpleMessage("Nowy worek"),
    "new_bag_properly_opened": m2,
    "new_box_opened_correctly": MessageLookupByLibrary.simpleMessage(
      "Nowa jednostka zbiorcza otwarta prawidłowo",
    ),
    "next_stage_edit_impossible": MessageLookupByLibrary.simpleMessage(
      "W dalszym etapie edycja zwrotu nie będzie już możliwa",
    ),
    "no_access_contact_admin": MessageLookupByLibrary.simpleMessage(
      "Nie posiadasz uprawnień do korzystania z tej aplikacji.",
    ),
    "no_bags_in_current_pickup": MessageLookupByLibrary.simpleMessage(
      "Brak worków w otwartym wydaniu.",
    ),
    "no_bags_to_display": MessageLookupByLibrary.simpleMessage(
      "Brak worków do wyświetlenia",
    ),
    "no_bags_were_selected": MessageLookupByLibrary.simpleMessage(
      "Nie wybrano żadnych worków",
    ),
    "no_boxes_to_display": MessageLookupByLibrary.simpleMessage(
      "Brak jednostek zbiorczych do wyświetlenia",
    ),
    "no_chosen_printer": MessageLookupByLibrary.simpleMessage(
      "Brak wybranej drukarki",
    ),
    "no_closed_bags": MessageLookupByLibrary.simpleMessage(
      "Brak zamkniętych worków",
    ),
    "no_internet": MessageLookupByLibrary.simpleMessage(
      "Brak połączenia - spróbuj ponownie!",
    ),
    "no_open_bags": MessageLookupByLibrary.simpleMessage(
      "Brak otwartych worków",
    ),
    "no_open_bags_of_this_type": MessageLookupByLibrary.simpleMessage(
      "Brak otwartych worków danego typu",
    ),
    "no_packages_in_open_bag": MessageLookupByLibrary.simpleMessage(
      "Brak opakowań w otwartym worku",
    ),
    "no_packeges_in_return": MessageLookupByLibrary.simpleMessage(
      "Brak opakowań w otwartym zwrocie.",
    ),
    "no_pickups": MessageLookupByLibrary.simpleMessage("Brak wydań"),
    "no_printer_configured": MessageLookupByLibrary.simpleMessage(
      "Brak drukarki, przejdź do Ustawień i dodaj urządzenie",
    ),
    "no_receivals": MessageLookupByLibrary.simpleMessage("Brak przyjęć"),
    "no_received_bags": MessageLookupByLibrary.simpleMessage(
      "Brak przyjętych worków.",
    ),
    "no_returns_selected_date": MessageLookupByLibrary.simpleMessage(
      "Brak zwrotów dla wybranej daty.",
    ),
    "no_returns_today": MessageLookupByLibrary.simpleMessage(
      "Brak zwrotów z dzisiejszą datą",
    ),
    "of_a_box": MessageLookupByLibrary.simpleMessage("jednostki zbiorczej"),
    "of_all_boxes": MessageLookupByLibrary.simpleMessage(
      "wszystkich jednostek zbiorczych?",
    ),
    "ok_name": MessageLookupByLibrary.simpleMessage("OK Operator Kaucyjny"),
    "open": MessageLookupByLibrary.simpleMessage("Otwarty"),
    "open_bag": MessageLookupByLibrary.simpleMessage("Worek otwarty"),
    "open_bags_has_been_fetched": MessageLookupByLibrary.simpleMessage(
      "Otwarte worki zostały pobrane",
    ),
    "open_bags_list": MessageLookupByLibrary.simpleMessage(
      "Lista otwartych worków",
    ),
    "open_new_bag": MessageLookupByLibrary.simpleMessage("Otwórz nowy worek"),
    "open_new_bag_CAN": MessageLookupByLibrary.simpleMessage(
      "Otwórz nowy worek Puszka",
    ),
    "open_new_bag_plastic": MessageLookupByLibrary.simpleMessage(
      "Otwórz nowy worek Plastik",
    ),
    "open_new_box": MessageLookupByLibrary.simpleMessage(
      "Otwórz nową jednostkę zbiorczą",
    ),
    "or_enter_bag_number": MessageLookupByLibrary.simpleMessage(
      "lub wpisz numer worka",
    ),
    "or_enter_box_number": MessageLookupByLibrary.simpleMessage(
      "lub wpisz numer jednostki zbiorczej",
    ),
    "or_enter_ean": MessageLookupByLibrary.simpleMessage("lub wpisz numer EAN"),
    "or_enter_label_number": MessageLookupByLibrary.simpleMessage(
      "lub wpisz numer etykiety",
    ),
    "or_enter_number": MessageLookupByLibrary.simpleMessage("lub wpisz numer"),
    "or_enter_seal_number": MessageLookupByLibrary.simpleMessage(
      "lub wpisz numer plomby",
    ),
    "or_search_by_label": MessageLookupByLibrary.simpleMessage(
      "lub wyszukaj po etykiecie",
    ),
    "order_pickup": MessageLookupByLibrary.simpleMessage("Zamówienie odbioru"),
    "package_receival": MessageLookupByLibrary.simpleMessage(
      "Przyjęcie opakowań",
    ),
    "packages_in_bag": MessageLookupByLibrary.simpleMessage(
      "Lista opakowań w worku",
    ),
    "packages_on_the_way": MessageLookupByLibrary.simpleMessage(
      "Opakowania w drodze",
    ),
    "packages_receival_confirmation": MessageLookupByLibrary.simpleMessage(
      "Potwierdzono przyjęcie opakowań",
    ),
    "packages_receival_confirmation_duplicates":
        MessageLookupByLibrary.simpleMessage(
          "Potwierdzono przyjęcie opakowań. Informacja: Niektóre worki w tym przyjęciu zostały już wcześniej zeskanowane. System rozpoznaje je jako jedną operację i nie wymaga dodatkowych działań.",
        ),
    "packages_return": MessageLookupByLibrary.simpleMessage("Zwrot opakowań"),
    "partially_received": MessageLookupByLibrary.simpleMessage(
      "Częściowo przyjęty",
    ),
    "pet_quantity": MessageLookupByLibrary.simpleMessage(
      "Butelki plastikowe (sztuki):",
    ),
    "pickup": MessageLookupByLibrary.simpleMessage("Wydanie"),
    "pickup_confirmation_printed_again": MessageLookupByLibrary.simpleMessage(
      "Dokument potwierdzający wydanie został ponownie wydrukowany.",
    ),
    "pickup_confirmation_subtitle": MessageLookupByLibrary.simpleMessage(
      "Jednocześnie wydrukowane zostaną dwie kopie potwierdzenia wydania. Podpisz i przekaż je kierowcy!",
    ),
    "pickup_confirmed": MessageLookupByLibrary.simpleMessage(
      "Potwierdzono wydanie kierowcy",
    ),
    "pickup_confirmed_with_print_error": MessageLookupByLibrary.simpleMessage(
      "Potwierdzono wydanie kierowcy.\nWystąpił błąd podczas drukowania dokumentu. Spróbuj ponownie, przechodząc do szczegółów wydania",
    ),
    "pickup_not_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono wydania o podanym id",
    ),
    "pickup_summary": MessageLookupByLibrary.simpleMessage(
      "Podsumowanie wydania",
    ),
    "pickups": MessageLookupByLibrary.simpleMessage("Wydania"),
    "pickups_overview": MessageLookupByLibrary.simpleMessage(
      "Zestawienie wydań",
    ),
    "pieces": MessageLookupByLibrary.simpleMessage("Sztuki"),
    "planned_receival": MessageLookupByLibrary.simpleMessage(
      "Planowane przyjęcia",
    ),
    "plastic": MessageLookupByLibrary.simpleMessage("Plastik"),
    "pln_return_sum": MessageLookupByLibrary.simpleMessage("Suma zwrotu PLN"),
    "pln_sum": MessageLookupByLibrary.simpleMessage("Suma PLN"),
    "print_pickup_confirmation": MessageLookupByLibrary.simpleMessage(
      "Drukuj potwierdzenie wydania",
    ),
    "print_voucher": MessageLookupByLibrary.simpleMessage("Drukuj bon"),
    "print_voucher_for_client": MessageLookupByLibrary.simpleMessage(
      "Drukuj BON dla Klienta",
    ),
    "printer_bluetooth_address_not_valid_error_message":
        MessageLookupByLibrary.simpleMessage(
          "Błąd konfiguracji drukarki - upewnij się, że wybrana drukarka jest poprawnie skonfigurowana.",
        ),
    "printer_bluetooth_not_turned_on_error_message":
        MessageLookupByLibrary.simpleMessage(
          "Błąd wydruku: brak połączenia z drukarką. Sprawdź, czy Bluetooth jest włączony i spróbuj ponownie.",
        ),
    "printer_config": MessageLookupByLibrary.simpleMessage(
      "Konfiguracja drukarki",
    ),
    "printer_not_turned_on_error_message": MessageLookupByLibrary.simpleMessage(
      "Błąd wydruku: upewnij się, że drukarka jest włączona i poprawnie podłączona.",
    ),
    "printer_was_chosen": m3,
    "properly_opened": MessageLookupByLibrary.simpleMessage(
      "otwarty prawidłowo",
    ),
    "quantity_less_or_equal_zero": MessageLookupByLibrary.simpleMessage(
      "Ilość musi być większa od zera",
    ),
    "reason_for_voucher_print_cancelation":
        MessageLookupByLibrary.simpleMessage(
          "Wybierz powód aby zrezygnować z wydruku bonu:",
        ),
    "reason_invalid": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy powód zmiany plomby / etykiety",
    ),
    "receival": MessageLookupByLibrary.simpleMessage("Przyjęcie"),
    "receival_summary": MessageLookupByLibrary.simpleMessage(
      "Podsumowanie przyjęcia",
    ),
    "receival_tally": MessageLookupByLibrary.simpleMessage(
      "Zestawienie przyjęć",
    ),
    "received_in_cc": MessageLookupByLibrary.simpleMessage("Przyjęty w CC"),
    "refresh_remote_config": MessageLookupByLibrary.simpleMessage(
      "Odśwież konfigurację zdalną",
    ),
    "reject": MessageLookupByLibrary.simpleMessage("Odrzuć"),
    "reject_return": MessageLookupByLibrary.simpleMessage("Odrzuć zwrot"),
    "released": MessageLookupByLibrary.simpleMessage("Wydano kierowcy"),
    "remove": MessageLookupByLibrary.simpleMessage("Usuń"),
    "removed_last_printer": MessageLookupByLibrary.simpleMessage(
      "Usunięto ostatnio dodaną drukarkę",
    ),
    "reprint_voucher_confirmation": MessageLookupByLibrary.simpleMessage(
      "Bon został wydrukowany",
    ),
    "return_closed_print_voucher": MessageLookupByLibrary.simpleMessage(
      "Zwrot został zamknięty. Wydrukuj bon.",
    ),
    "return_closed_show_voucher": MessageLookupByLibrary.simpleMessage(
      "Zwrot został zamknięty. Wyświetl bon.",
    ),
    "return_deposing_packages": MessageLookupByLibrary.simpleMessage(
      "Zwrot opakowań kaucyjnych",
    ),
    "return_finish_confirmation": MessageLookupByLibrary.simpleMessage(
      "Potwierdzenie zakończenia zwrotu opakowań",
    ),
    "return_glass_bottles": MessageLookupByLibrary.simpleMessage(
      "Zwrot opakowań: Szkło",
    ),
    "return_glass_bottles_title": MessageLookupByLibrary.simpleMessage(
      "Zwrot opakowań szklanych",
    ),
    "return_plastics_cans": MessageLookupByLibrary.simpleMessage(
      "Zwrot opakowań: Plastik, Puszka",
    ),
    "return_summary": MessageLookupByLibrary.simpleMessage(
      "Podsumowanie zwrotu",
    ),
    "return_text": MessageLookupByLibrary.simpleMessage("Zwrot"),
    "returning_packages_list": MessageLookupByLibrary.simpleMessage(
      "Lista zwracanych opakowań",
    ),
    "returns_archive": MessageLookupByLibrary.simpleMessage("Archiwum zwrotów"),
    "saturday_short": MessageLookupByLibrary.simpleMessage("So"),
    "scan_bag_code": MessageLookupByLibrary.simpleMessage("Zeskanuj kod worka"),
    "scan_bag_seal_code": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod plomby worka",
    ),
    "scan_bag_seal_code_pickup": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod plomby worka i dodaj worek do wydania",
    ),
    "scan_box_label_or_pick_from_list": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod jednostki zbiorczej, wybierz z listy",
    ),
    "scan_new_bag": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod nowego worka",
    ),
    "scan_new_bag_label_code": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod nowej etykiety worka",
    ),
    "scan_new_box": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod nowej jednostki zbiorczej",
    ),
    "scan_new_printer_code": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod nowej drukarki",
    ),
    "scan_new_seal": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj nową plombę",
    ),
    "scan_new_seal_code": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod nowej plomby",
    ),
    "scan_or_pick_bag_number": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod worka, wybierz z listy",
    ),
    "scan_package_ean": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj EAN opakowania",
    ),
    "scan_seal": MessageLookupByLibrary.simpleMessage("Zeskanuj kod plomby"),
    "scan_seal_and_add_bag_to_pickup": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod plomby worka \ni dodaj worek do wydania",
    ),
    "scan_seal_and_add_bag_to_receival": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod plomby worka \ni dodaj worek do przyjęcia",
    ),
    "scan_seal_or_pick_from_list": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod plomby, wybierz z listy",
    ),
    "scanned_package_must_be_assigned_to_bag":
        MessageLookupByLibrary.simpleMessage(
          "Zeskanowane opakowanie musi zostać przypisane do worka.",
        ),
    "scanned_package_of_not_allowed_type": MessageLookupByLibrary.simpleMessage(
      "Zeskanowany typ opakowania nie jest obsługiwany w Twoim punkcie zbiórki.",
    ),
    "scanned_package_requires_bag_change": MessageLookupByLibrary.simpleMessage(
      "Zeskanowane opakowanie wymaga zmiany worka.",
    ),
    "seal": MessageLookupByLibrary.simpleMessage("Plomba"),
    "seal_added_successfully": MessageLookupByLibrary.simpleMessage(
      "Worek został zaplombowany.",
    ),
    "seal_already_exists": MessageLookupByLibrary.simpleMessage(
      "Plomba o podanym numerze już istnieje",
    ),
    "seal_another_bag": MessageLookupByLibrary.simpleMessage(
      "Zaplombuj kolejny worek",
    ),
    "seal_bag": MessageLookupByLibrary.simpleMessage("Zaplombuj worek"),
    "seal_changed_succesfully": MessageLookupByLibrary.simpleMessage(
      "Plomba została zmieniona pomyślnie.",
    ),
    "seal_empty": MessageLookupByLibrary.simpleMessage(
      "Numer plomby nie może być pusty",
    ),
    "seal_number": MessageLookupByLibrary.simpleMessage("Numer plomby"),
    "seal_scan_success": MessageLookupByLibrary.simpleMessage(
      "Zeskanowano kod plomby.",
    ),
    "seal_was_added_successfully": MessageLookupByLibrary.simpleMessage(
      "Plomba została dodana prawidłowo.",
    ),
    "sealed": MessageLookupByLibrary.simpleMessage("Zaplombowany"),
    "sealed_bag": MessageLookupByLibrary.simpleMessage("Worek zaplombowany"),
    "sealed_bags_list": MessageLookupByLibrary.simpleMessage(
      "Lista worków zaplombowanych",
    ),
    "security_deposit_voucher": MessageLookupByLibrary.simpleMessage(
      "Bon kaucyjny",
    ),
    "select_all": MessageLookupByLibrary.simpleMessage("Zaznacz wszystkie"),
    "selected_bags": MessageLookupByLibrary.simpleMessage("Wybrane worki"),
    "selected_day": m4,
    "sent_bags": MessageLookupByLibrary.simpleMessage("Wysłane worki"),
    "server_error": MessageLookupByLibrary.simpleMessage(
      "Błąd serwera. Proszę spróbować później.",
    ),
    "session_expired": MessageLookupByLibrary.simpleMessage(
      "Sesja wygasła, zaloguj się ponownie",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Ustawienia"),
    "show_voucher": MessageLookupByLibrary.simpleMessage("Wyświetl bon"),
    "submit_boxes_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Zgłoś jednostki zbiorcze do odbioru",
    ),
    "submitted_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Zgłoszone do odbioru",
    ),
    "summary": MessageLookupByLibrary.simpleMessage("Podsumowanie"),
    "sunday_short": MessageLookupByLibrary.simpleMessage("Nd"),
    "technical_issue": MessageLookupByLibrary.simpleMessage(
      "Problem techniczny",
    ),
    "terms_and_condition_paragraph_1": MessageLookupByLibrary.simpleMessage(
      "I. Wstęp: Nasze zobowiązanie do ochrony danych naszych użytkowników",
    ),
    "terms_and_conditions_part_1": MessageLookupByLibrary.simpleMessage(
      "W dzisiejszym cyfrowym świecie, gdzie dane stały się kluczowym zasobem, OK OPERATOR KAUCYJNY S.A. uznaje ochronę danych osobowych za fundamentalny element naszej działalności. Jesteśmy głęboko przekonani, że zaufanie osób, które korzystają z oferowanych przez nas usług oraz naszych kontrahentów jest nie tylko przywilejem, ale i zobowiązaniem, które traktujemy z najwyższą powagą.",
    ),
    "terms_and_conditions_part_2": MessageLookupByLibrary.simpleMessage(
      "Nasza firma, działająca w branży kaucyjnej, zdaje sobie sprawę, że skuteczna ochrona danych osobowych jest kluczowa dla utrzymania integralności naszych procesów biznesowych, budowania długotrwałych relacji z partnerami oraz zapewnienia zgodności z obowiązującymi przepisami prawa. Dlatego też ochrona danych osobowych nie jest dla nas jedynie obowiązkiem prawnym, ale stanowi integralną część naszej kultury organizacyjnej i etyki biznesowej.",
    ),
    "terms_and_conditions_part_3": MessageLookupByLibrary.simpleMessage(
      "W OK OPERATOR KAUCYJNY S.A. wierzymy, że transparentność w zakresie przetwarzania danych osobowych jest podstawą zaufania w relacjach biznesowych. Dlatego dokładamy wszelkich starań, aby zapewnić naszym partnerom i klientom pełną przejrzystość w zakresie tego, jak gromadzimy, przetwarzamy i chronimy ich dane osobowe. Nasza polityka prywatności jest wyrazem tego zaangażowania – stanowi ona kompleksowy przewodnik po naszych praktykach w zakresie ochrony danych.",
    ),
    "terms_and_conditions_part_4": MessageLookupByLibrary.simpleMessage(
      "Inwestujemy znaczące środki w najnowocześniejsze rozwiązania technologiczne i organizacyjne, aby zagwarantować najwyższy poziom bezpieczeństwa powierzonych nam danych. Regularnie przeprowadzamy audyty i aktualizacje naszych systemów, aby sprostać wciąż ewoluującym zagrożeniom w cyberprzestrzeni. Jednocześnie prowadzimy ciągłe szkolenia naszych pracowników, aby mieli oni pełną świadomość znaczenia ochrony danych osobowych i znali najlepsze praktyki w tym zakresie.",
    ),
    "terms_and_conditions_part_5": MessageLookupByLibrary.simpleMessage(
      "Rozumiemy, że w dynamicznym środowisku biznesowym, efektywna wymiana informacji jest kluczowa dla sukcesu. Dlatego też, dbając o ochronę danych, staramy się jednocześnie zapewnić naszym partnerom i klientom płynność procesów biznesowych. Nasza polityka prywatności jest skonstruowana w taki sposób, aby umożliwić efektywną współpracę przy jednoczesnym zachowaniu najwyższych standardów ochrony danych.",
    ),
    "terms_and_conditions_part_6": MessageLookupByLibrary.simpleMessage(
      "W OK OPERATOR KAUCYJNY S.A. jesteśmy przekonani, że odpowiedzialne zarządzanie danymi osobowymi jest nie tylko obowiązkiem prawnym, ale również kluczowym czynnikiem budującym zaufanie i lojalność naszych partnerów biznesowych i klientów. Dlatego zobowiązujemy się do ciągłego doskonalenia naszych praktyk w zakresie ochrony danych, adaptacji do zmieniających się realiów prawnych i technologicznych oraz otwartego dialogu z naszymi interesariuszami w kwestiach związanych z prywatnością danych.",
    ),
    "terms_and_conditions_part_7": MessageLookupByLibrary.simpleMessage(
      "Zapraszamy do zapoznania się z naszą szczegółową polityką prywatności, która stanowi odzwierciedlenie naszego zaangażowania w ochronę Państwa danych osobowych. Jesteśmy przekonani, że dzięki tym działaniom budujemy nie tylko bezpieczne, ale i trwałe relacje biznesowe, oparte na wzajemnym zaufaniu i respekcie dla prywatności.",
    ),
    "terms_and_conditions_title": MessageLookupByLibrary.simpleMessage(
      "Regulamin aplikacji mobilnej OK",
    ),
    "test_application_insights": MessageLookupByLibrary.simpleMessage(
      "Test Application Insights",
    ),
    "thursday_short": MessageLookupByLibrary.simpleMessage("Cz"),
    "token_not_provided": MessageLookupByLibrary.simpleMessage(
      "Nie podano tokena",
    ),
    "torn_bag": MessageLookupByLibrary.simpleMessage("Rozerwany worek"),
    "torn_box": MessageLookupByLibrary.simpleMessage(
      "Rozerwana jednostka zbiorcza",
    ),
    "total_quantity": MessageLookupByLibrary.simpleMessage("Łącznie:"),
    "tuesday_short": MessageLookupByLibrary.simpleMessage("Wt"),
    "type_invalid": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy typ worka",
    ),
    "type_not_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono podanego typu worka",
    ),
    "unknown_ean_code": MessageLookupByLibrary.simpleMessage(
      "Nieznany kod EAN",
    ),
    "unreadable_label": MessageLookupByLibrary.simpleMessage(
      "Nieczytelna etykieta",
    ),
    "unreadable_seal": MessageLookupByLibrary.simpleMessage(
      "Nieczytelna plomba",
    ),
    "user_not_authorized": MessageLookupByLibrary.simpleMessage(
      "Nie masz uprawnień do tej akcji",
    ),
    "voucher_generation_date": MessageLookupByLibrary.simpleMessage(
      "Data wygenerowania bonu",
    ),
    "voucher_issuance": MessageLookupByLibrary.simpleMessage("Wydanie bonu"),
    "voucher_printed_for_client": MessageLookupByLibrary.simpleMessage(
      "Bon został wydrukowany",
    ),
    "wednesday_short": MessageLookupByLibrary.simpleMessage("Śr"),
    "welcome_to_system": MessageLookupByLibrary.simpleMessage(
      "Witaj w systemie",
    ),
    "wrong_device_to_cc": MessageLookupByLibrary.simpleMessage(
      "Błędne przypisanie urządzenia do centrum zliczania.",
    ),
    "wrong_device_to_collection_point": MessageLookupByLibrary.simpleMessage(
      "Błędne przypisanie urządzenia do punktu zbiórki.",
    ),
    "wrong_device_to_retail_chain": MessageLookupByLibrary.simpleMessage(
      "Błędne przypisanie urządzenia do sieci handlowej.",
    ),
    "wrong_package_type": MessageLookupByLibrary.simpleMessage(
      "Zeskanowane opakowanie nie jest opakowaniem",
    ),
    "wrong_user_configuration": MessageLookupByLibrary.simpleMessage(
      "Użytkownik nie został poprawnie skonfigurowany.",
    ),
    "wrong_user_to_cc": MessageLookupByLibrary.simpleMessage(
      "Błędne przypisanie użytkownika do centrum zliczania.",
    ),
    "wrong_user_to_collection_point": MessageLookupByLibrary.simpleMessage(
      "Błędne przypisanie użytkownika do punktu zbiórki.",
    ),
    "wrong_user_to_retail_chain": MessageLookupByLibrary.simpleMessage(
      "Błędne przypisanie użytkownika do sieci handlowej.",
    ),
  };
}
