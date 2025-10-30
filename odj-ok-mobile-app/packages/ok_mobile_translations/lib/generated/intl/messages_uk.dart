// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a uk locale. All the
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
  String get localeName => 'uk';

  static String m0(id) => "Вибрано мішок ${id}.";

  static String m1(id, type) => "Вибрано мішок ${type} ${id}.";

  static String m2(id) => "Новий мішок ${id} відкритий правильно.";

  static String m3(mac_address) => "Вибрано принтер ${mac_address}";

  static String m4(day) => "Вибрано день: ${day}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept_terms": MessageLookupByLibrary.simpleMessage(
      "Прийняття регламенту",
    ),
    "accept_terms_and_conditions": MessageLookupByLibrary.simpleMessage(
      "Приймаю регламент",
    ),
    "actual_return_full_packages_list": MessageLookupByLibrary.simpleMessage(
      "Повний список упаковок в актуальному поверненні",
    ),
    "add_bags_to_box": MessageLookupByLibrary.simpleMessage(
      "Додати мішки до коробки",
    ),
    "add_printer_to_start_pickup": MessageLookupByLibrary.simpleMessage(
      "Додайте принтер, щоб розпочати видачу",
    ),
    "add_printer_to_start_return": MessageLookupByLibrary.simpleMessage(
      "Додайте принтер, щоб розпочати повернення заставних упаковок",
    ),
    "add_seal": MessageLookupByLibrary.simpleMessage("Додати пломбу"),
    "add_to_box": MessageLookupByLibrary.simpleMessage("Додати до коробки"),
    "added_seal": MessageLookupByLibrary.simpleMessage("Пломба додана"),
    "admin": MessageLookupByLibrary.simpleMessage("Адміністрування"),
    "all_bags_added_to_box": MessageLookupByLibrary.simpleMessage(
      "Сумки були додані до колекційної одиниці",
    ),
    "all_boxes_closed": MessageLookupByLibrary.simpleMessage(
      "Усі колекційні одиниці були закриті",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "bag": MessageLookupByLibrary.simpleMessage("Мішок"),
    "bag_already_added_to_box": MessageLookupByLibrary.simpleMessage(
      "Ця сумка вже призначена для колекційної одиниці",
    ),
    "bag_already_added_to_pickup": MessageLookupByLibrary.simpleMessage(
      "Мішок із зазначеним номером вже доданий до видачі.",
    ),
    "bag_already_added_to_receival": MessageLookupByLibrary.simpleMessage(
      "Мішок із зазначеним номером вже доданий до прийому.",
    ),
    "bag_already_closed": MessageLookupByLibrary.simpleMessage(
      "Просканований мішок вже закритий.",
    ),
    "bag_already_received": MessageLookupByLibrary.simpleMessage(
      "Мішок вже прийнятий",
    ),
    "bag_choice": MessageLookupByLibrary.simpleMessage("Вибір мішка"),
    "bag_chosen": MessageLookupByLibrary.simpleMessage("Вибраний мішок"),
    "bag_closed_choose_open_instead": MessageLookupByLibrary.simpleMessage(
      "Вибраний мішок є закритим, відскануйте етикетку відкритого мішка.",
    ),
    "bag_contains_open_return_packages": MessageLookupByLibrary.simpleMessage(
      "У мішку є упаковки з відкритого повернення. Закрийте повернення.",
    ),
    "bag_correctly_chosen": MessageLookupByLibrary.simpleMessage(
      "Мішок вибрано правильно.",
    ),
    "bag_correctly_opened": MessageLookupByLibrary.simpleMessage(
      "Мішок відкритий правильно.",
    ),
    "bag_empty": MessageLookupByLibrary.simpleMessage(
      "Номер мішка не може бути порожнім",
    ),
    "bag_incorrect_collection_point": MessageLookupByLibrary.simpleMessage(
      "Мішок із зазначеним id не прив’язаний до вашого пункту збору.",
    ),
    "bag_incorrect_item_for_bag": MessageLookupByLibrary.simpleMessage(
      "Упаковка має інший тип, ніж зазначений для мішка.",
    ),
    "bag_is_open": MessageLookupByLibrary.simpleMessage("Мішок відкритий"),
    "bag_not_assigned_to_collection_point":
        MessageLookupByLibrary.simpleMessage(
          "Цей мішок не призначено для вашої точки збору",
        ),
    "bag_not_closed": MessageLookupByLibrary.simpleMessage(
      "Мішок не можна додати до коробки, оскільки він не закритий.",
    ),
    "bag_not_found": MessageLookupByLibrary.simpleMessage(
      "Мішок з вказаним кодом не знайдений",
    ),
    "bag_not_released": MessageLookupByLibrary.simpleMessage(
      "Мішок не був виданий",
    ),
    "bag_selected_for_closing": MessageLookupByLibrary.simpleMessage(
      "Вибрано мішок для закриття.",
    ),
    "bag_selected_for_label_change": MessageLookupByLibrary.simpleMessage(
      "Вибрано мішок для зміни етикетки.",
    ),
    "bag_selected_for_seal_change": MessageLookupByLibrary.simpleMessage(
      "Вибрано мішок для зміни пломби.",
    ),
    "bag_summary": MessageLookupByLibrary.simpleMessage("Подсумування мішка"),
    "bag_was_added_to_box": MessageLookupByLibrary.simpleMessage(
      "Мішок додано до коробки",
    ),
    "bag_was_chosen": m0,
    "bag_was_chosen_with_type": m1,
    "bag_was_closed": MessageLookupByLibrary.simpleMessage(
      "Мішок був закритий.",
    ),
    "bag_was_removed_from_box": MessageLookupByLibrary.simpleMessage(
      "Мішок було видалено з коробки",
    ),
    "bags": MessageLookupByLibrary.simpleMessage("Мішки"),
    "bags_management": MessageLookupByLibrary.simpleMessage(
      "Управління мішками",
    ),
    "before_print": MessageLookupByLibrary.simpleMessage("Перед друком"),
    "box": MessageLookupByLibrary.simpleMessage("Коробка"),
    "box_already_closed": MessageLookupByLibrary.simpleMessage(
      "Колекційну одиницю вже було закрито",
    ),
    "box_correctly_opened": MessageLookupByLibrary.simpleMessage(
      "Коробка відкрита правильно",
    ),
    "box_empty": MessageLookupByLibrary.simpleMessage(
      "Номер коробки не може бути порожнім",
    ),
    "box_ids_empty": MessageLookupByLibrary.simpleMessage(
      "Список ID коробок не може бути порожнім",
    ),
    "box_not_assigned_to_collection_point":
        MessageLookupByLibrary.simpleMessage(
          "Ця колекційна одиниця не призначена для вашої точки збору",
        ),
    "box_not_found": MessageLookupByLibrary.simpleMessage(
      "Коробку не знайдено",
    ),
    "box_summary": MessageLookupByLibrary.simpleMessage("Резюме коробки"),
    "box_was_closed": MessageLookupByLibrary.simpleMessage(
      "Колекційну одиницю закрито",
    ),
    "boxes": MessageLookupByLibrary.simpleMessage("Групові одиниці"),
    "camera_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Доступ до камери відхилено",
    ),
    "can": MessageLookupByLibrary.simpleMessage("Пляшка"),
    "can_quantity": MessageLookupByLibrary.simpleMessage("Бляшанки (шт.):"),
    "cancel_voucher_print": MessageLookupByLibrary.simpleMessage(
      "Скасувати друк ваучера",
    ),
    "canceled": MessageLookupByLibrary.simpleMessage("Скасований"),
    "cancelled_print": MessageLookupByLibrary.simpleMessage("Скасований друк"),
    "cc_empty": MessageLookupByLibrary.simpleMessage(
      "Немає номера Counting Center",
    ),
    "cc_not_found": MessageLookupByLibrary.simpleMessage(
      "Не знайдено Counting Center із зазначеним id",
    ),
    "change_bag": MessageLookupByLibrary.simpleMessage("Змінити мішок"),
    "change_box_label": MessageLookupByLibrary.simpleMessage(
      "Змінити етикетку коробки",
    ),
    "change_label": MessageLookupByLibrary.simpleMessage("Змінити етикетку"),
    "change_label_or_bag": MessageLookupByLibrary.simpleMessage(
      "Змінити етикетку/мішок",
    ),
    "change_seal": MessageLookupByLibrary.simpleMessage("Змінити пломбу"),
    "change_seal_after_label_change": MessageLookupByLibrary.simpleMessage(
      "У випадку опломбованого мішка необхідно змінити як етикетку, так і пломбу.",
    ),
    "choose_open_bag": MessageLookupByLibrary.simpleMessage(
      "Вибрати відкритий мішок",
    ),
    "choose_open_bag_CAN": MessageLookupByLibrary.simpleMessage(
      "Вибрати відкритий мішок Пушка",
    ),
    "choose_open_bag_plastic": MessageLookupByLibrary.simpleMessage(
      "Вибрати відкритий мішок Пластик",
    ),
    "choose_open_box": MessageLookupByLibrary.simpleMessage(
      "Вибрати відкриту коробку",
    ),
    "choose_reason_for_label_change": MessageLookupByLibrary.simpleMessage(
      "Виберіть причину зміни етикетки",
    ),
    "choose_reason_for_label_or_bag_change":
        MessageLookupByLibrary.simpleMessage(
          "Виберіть причину зміни етикетки / мішку:",
        ),
    "choose_reason_for_seal_change": MessageLookupByLibrary.simpleMessage(
      "Оберіть причину зміни пломби:",
    ),
    "choose_voucher_print_reason": MessageLookupByLibrary.simpleMessage(
      "Виберіть причину друку ваучера:",
    ),
    "choose_voucher_reprint_reason": MessageLookupByLibrary.simpleMessage(
      "Виберіть причину повторного друку ваучера:",
    ),
    "chosen_bag": MessageLookupByLibrary.simpleMessage("Вибрано мішок"),
    "chosen_bag_for_packages": MessageLookupByLibrary.simpleMessage(
      "Вибраний мішок для упаковок",
    ),
    "chosen_printer": MessageLookupByLibrary.simpleMessage("Вибрано принтер"),
    "client_resignation": MessageLookupByLibrary.simpleMessage(
      "Відмова клієнта",
    ),
    "close_and_seal": MessageLookupByLibrary.simpleMessage(
      "Закрити і опломбувати мішок",
    ),
    "close_bag": MessageLookupByLibrary.simpleMessage("Закрити мішок"),
    "close_box": MessageLookupByLibrary.simpleMessage("Закрити коробку"),
    "close_boxes": MessageLookupByLibrary.simpleMessage("Закрити коробку"),
    "closed": MessageLookupByLibrary.simpleMessage("Закрито"),
    "closed_bag": MessageLookupByLibrary.simpleMessage("Закритий мішок"),
    "closed_bags": MessageLookupByLibrary.simpleMessage("Закриті мішки"),
    "closed_bags_list": MessageLookupByLibrary.simpleMessage(
      "Список закритих мішків",
    ),
    "closed_returns": MessageLookupByLibrary.simpleMessage(
      "Закриті повернення",
    ),
    "closed_returns_archive": MessageLookupByLibrary.simpleMessage(
      "Архів закритих повернень",
    ),
    "closed_returns_list": MessageLookupByLibrary.simpleMessage(
      "Список закритих повернень",
    ),
    "collected_packages": MessageLookupByLibrary.simpleMessage(
      "Прийняті упаковки",
    ),
    "collection_point_id_empty": MessageLookupByLibrary.simpleMessage(
      "ID пункту збору не може бути порожнім",
    ),
    "collection_point_not_exist": MessageLookupByLibrary.simpleMessage(
      "Пункт збору з вказаним ID не існує",
    ),
    "comment_empty": MessageLookupByLibrary.simpleMessage(
      "Коментар не може бути порожнім",
    ),
    "configure_printer": MessageLookupByLibrary.simpleMessage(
      "Налаштувати принтер",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Підтвердити"),
    "confirm_and_print_document": MessageLookupByLibrary.simpleMessage(
      "Підтвердити і друкувати документ",
    ),
    "confirm_pickup": MessageLookupByLibrary.simpleMessage(
      "Підтвердити видачу",
    ),
    "confirm_receival": MessageLookupByLibrary.simpleMessage(
      "Підтвердити прийом",
    ),
    "confirm_voucher_print": MessageLookupByLibrary.simpleMessage(
      "Підтвердити друк чеку для повернення",
    ),
    "contact_admin": MessageLookupByLibrary.simpleMessage(
      "Щоб вирішити проблему, зверніться до адміністратора.",
    ),
    "correct": MessageLookupByLibrary.simpleMessage("Правильний"),
    "correct_print": MessageLookupByLibrary.simpleMessage("Правильний друк"),
    "current_receival": MessageLookupByLibrary.simpleMessage(
      "Актуальне приймання",
    ),
    "current_release": MessageLookupByLibrary.simpleMessage(
      "Актуальне видання",
    ),
    "current_return": MessageLookupByLibrary.simpleMessage(
      "Актуальний повернення",
    ),
    "damaged_bag": MessageLookupByLibrary.simpleMessage("Пошкоджений мішок"),
    "damaged_label": MessageLookupByLibrary.simpleMessage(
      "Пошкоджена етикетка",
    ),
    "damaged_seal": MessageLookupByLibrary.simpleMessage("Пошкоджена пломба"),
    "days": MessageLookupByLibrary.simpleMessage("дні"),
    "declare_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Подати на вивезення",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Деталі"),
    "device_id_empty": MessageLookupByLibrary.simpleMessage(
      "ID пристрою не може бути порожнім.",
    ),
    "device_id_too_long": MessageLookupByLibrary.simpleMessage(
      "Вказано занадто довгий ID пристрою.",
    ),
    "device_not_configured": MessageLookupByLibrary.simpleMessage(
      "Пристрій не налаштований правильно.",
    ),
    "different_issue": MessageLookupByLibrary.simpleMessage("Інша проблема"),
    "different_reason": MessageLookupByLibrary.simpleMessage("Інша причина"),
    "do_you_really_want_to_close": MessageLookupByLibrary.simpleMessage(
      "Ви дійсно хочете підтвердити закриття",
    ),
    "duplicated_label_error": MessageLookupByLibrary.simpleMessage(
      "Мішок з таким номером вже існує в системі — змініть етикетку.",
    ),
    "ean": MessageLookupByLibrary.simpleMessage("EAN"),
    "ean_empty": MessageLookupByLibrary.simpleMessage(
      "EAN не може бути порожнім.",
    ),
    "ean_not_found": MessageLookupByLibrary.simpleMessage(
      "Не знайдено упаковку з указаним EAN.",
    ),
    "empty": MessageLookupByLibrary.simpleMessage("ПУСТИЙ"),
    "empty_bag_cannot_be_closed": MessageLookupByLibrary.simpleMessage(
      "Неможливо закрити порожній мішок.",
    ),
    "enter_bag_number": MessageLookupByLibrary.simpleMessage(
      "Введіть номер мішка",
    ),
    "environment": MessageLookupByLibrary.simpleMessage("Середовище"),
    "error_on_first_print": MessageLookupByLibrary.simpleMessage(
      "Помилка під час першого друку",
    ),
    "event_type_invalid": MessageLookupByLibrary.simpleMessage(
      "Невірний тип події",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("Вийти"),
    "expiration_date": MessageLookupByLibrary.simpleMessage("Дата закінчення"),
    "filter": MessageLookupByLibrary.simpleMessage("Фільтрувати:"),
    "finish_return": MessageLookupByLibrary.simpleMessage(
      "Завершити повернення",
    ),
    "friday_short": MessageLookupByLibrary.simpleMessage("Пт"),
    "general_printer_error_message": MessageLookupByLibrary.simpleMessage(
      "Не вдалося надрукувати документ. Перевірте конфігурацію принтера та підключення пристрою, а потім спробуйте ще раз.",
    ),
    "generic_error_message": MessageLookupByLibrary.simpleMessage(
      "Виникла помилка. Спробуйте ще раз або зверніться до адміністратора.",
    ),
    "glass": MessageLookupByLibrary.simpleMessage("Скло"),
    "glass_return": MessageLookupByLibrary.simpleMessage(
      "Повернення скляної тари",
    ),
    "handing_over_driver": MessageLookupByLibrary.simpleMessage(
      "Передача водієві",
    ),
    "i_confirm": MessageLookupByLibrary.simpleMessage("Підтверджую"),
    "i_confirm_finish": MessageLookupByLibrary.simpleMessage(
      "Підтверджую завершення повернення",
    ),
    "i_confirm_pickup": MessageLookupByLibrary.simpleMessage(
      "Підтверджую видачу водію задекларованих упаковок.",
    ),
    "if_you_see_this_screen": MessageLookupByLibrary.simpleMessage(
      "Якщо ви бачите цей екран, це означає, що служба працює правильно.",
    ),
    "illegible_voucher": MessageLookupByLibrary.simpleMessage(
      "Нерозбірливий ваучер",
    ),
    "incorrect_bag_number": MessageLookupByLibrary.simpleMessage(
      "Невірний номер мішка",
    ),
    "incorrect_seal_number": MessageLookupByLibrary.simpleMessage(
      "Невірний номер пломби.",
    ),
    "incorrectly_rejected": MessageLookupByLibrary.simpleMessage(
      "Неправильно відхилений",
    ),
    "insights_request_sent": MessageLookupByLibrary.simpleMessage(
      "Надіслано запит до сервісу Application Insights",
    ),
    "invalid": MessageLookupByLibrary.simpleMessage("Неправильний"),
    "invalid_credentials_info": MessageLookupByLibrary.simpleMessage(
      "Невірний логін або пароль.\nБудь ласка, увійдіть знову.",
    ),
    "invalid_device_id": MessageLookupByLibrary.simpleMessage(
      "Неправильний ID пристрою.",
    ),
    "invalid_package_type": MessageLookupByLibrary.simpleMessage(
      "Неправильний тип упаковки",
    ),
    "invalid_seal_format": MessageLookupByLibrary.simpleMessage(
      "Неправильний формат пломби.",
    ),
    "is_not_deposit_package": MessageLookupByLibrary.simpleMessage(
      "не є депозитною упаковкою",
    ),
    "item_already_has_status": MessageLookupByLibrary.simpleMessage(
      "Зазначений об\'єкт прив’язаний до іншої видачі",
    ),
    "item_incorrect_cc": MessageLookupByLibrary.simpleMessage(
      "Об\'єкт із зазначеним id не прив’язаний до вашого Counting Center",
    ),
    "item_incorrect_collection_point": MessageLookupByLibrary.simpleMessage(
      "Об\'єкт із зазначеним id не прив’язаний до вашого пункту збору",
    ),
    "item_not_closed": MessageLookupByLibrary.simpleMessage(
      "Об\'єкт із зазначеним id не закритий",
    ),
    "item_not_found": MessageLookupByLibrary.simpleMessage(
      "Не знайдено об\'єкт із зазначеним id",
    ),
    "item_not_released": MessageLookupByLibrary.simpleMessage(
      "Об\'єкт із зазначеним id не був виданий",
    ),
    "items_empty": MessageLookupByLibrary.simpleMessage(
      "Список об\'єктів не може бути порожнім",
    ),
    "label": MessageLookupByLibrary.simpleMessage("Етикетка"),
    "label_and_seal_changed": MessageLookupByLibrary.simpleMessage(
      "Змінено етикетку та пломбу мішка",
    ),
    "label_empty": MessageLookupByLibrary.simpleMessage(
      "Номер етикетки не може бути порожнім",
    ),
    "label_has_been_changed": MessageLookupByLibrary.simpleMessage(
      "Етикетка була змінена",
    ),
    "label_number": MessageLookupByLibrary.simpleMessage("Номер етикетки"),
    "label_scan_success": MessageLookupByLibrary.simpleMessage(
      "Етикетку мішка успішно відскановано.",
    ),
    "last_added": MessageLookupByLibrary.simpleMessage("Останній доданий"),
    "last_added_ean": MessageLookupByLibrary.simpleMessage(
      "Останній доданий EAN",
    ),
    "last_package_not_assigned_and_removed": MessageLookupByLibrary.simpleMessage(
      "Останню упаковку не було призначено до відкритого мішка, і її видалено зі списку. Повторно відскануйте EAN упаковки.",
    ),
    "last_package_removed_from_return": MessageLookupByLibrary.simpleMessage(
      "Останню відскановану упаковку було видалено зі списку повернених упаковок в актуальному поверненні.",
    ),
    "last_received": MessageLookupByLibrary.simpleMessage("Останній прийнятий"),
    "list_of_added_bags": MessageLookupByLibrary.simpleMessage(
      "Список доданих мішків",
    ),
    "list_of_bags_in_pickup": MessageLookupByLibrary.simpleMessage(
      "Список мішків у видачі",
    ),
    "log_in": MessageLookupByLibrary.simpleMessage("Увійти в систему"),
    "login": MessageLookupByLibrary.simpleMessage("Логін"),
    "logout": MessageLookupByLibrary.simpleMessage("Вихід"),
    "logout_cancelled": MessageLookupByLibrary.simpleMessage(
      "Процес виходу було скасовано",
    ),
    "lost_voucher": MessageLookupByLibrary.simpleMessage("Втрачений ваучер"),
    "make_sure_codes_are_correct": MessageLookupByLibrary.simpleMessage(
      "Перед підтвердженням переконайтесь, що коди правильно прив’язані до номера етикетки та пломби.",
    ),
    "manage_bags": MessageLookupByLibrary.simpleMessage("Управління мішками"),
    "manage_boxes": MessageLookupByLibrary.simpleMessage(
      "Управління коробками",
    ),
    "manuals": MessageLookupByLibrary.simpleMessage("Інструкції"),
    "mix": MessageLookupByLibrary.simpleMessage("Пластик / Бляшанка"),
    "monday_short": MessageLookupByLibrary.simpleMessage("Пн"),
    "new_bag": MessageLookupByLibrary.simpleMessage("Новий мішок"),
    "new_bag_properly_opened": m2,
    "new_box_opened_correctly": MessageLookupByLibrary.simpleMessage(
      "Нова коробка відкрита правильно",
    ),
    "next_stage_edit_impossible": MessageLookupByLibrary.simpleMessage(
      "На наступному етапі редагування повернення буде неможливим",
    ),
    "no_access_contact_admin": MessageLookupByLibrary.simpleMessage(
      "Ви не маєте прав доступу до цього додатку.",
    ),
    "no_bags_in_current_pickup": MessageLookupByLibrary.simpleMessage(
      "Немає мішків у відкритій видачі.",
    ),
    "no_bags_to_display": MessageLookupByLibrary.simpleMessage(
      "Немає сумок для відображення",
    ),
    "no_bags_were_selected": MessageLookupByLibrary.simpleMessage(
      "Не було вибрано жодної сумки",
    ),
    "no_boxes_to_display": MessageLookupByLibrary.simpleMessage(
      "Немає колекційних одиниць для відображення",
    ),
    "no_chosen_printer": MessageLookupByLibrary.simpleMessage(
      "Не вибрано принтер",
    ),
    "no_closed_bags": MessageLookupByLibrary.simpleMessage(
      "Немає закритих сумок",
    ),
    "no_internet": MessageLookupByLibrary.simpleMessage(
      "Немає з’єднання - спробуйте знову!",
    ),
    "no_open_bags": MessageLookupByLibrary.simpleMessage(
      "Немає відкритих мішків",
    ),
    "no_open_bags_of_this_type": MessageLookupByLibrary.simpleMessage(
      "Немає відкритих мішків цього типу",
    ),
    "no_packages_in_open_bag": MessageLookupByLibrary.simpleMessage(
      "Немає упаковок у відкритому мішку",
    ),
    "no_packeges_in_return": MessageLookupByLibrary.simpleMessage(
      "Немає упаковок у відкритому поверненні.",
    ),
    "no_pickups": MessageLookupByLibrary.simpleMessage("Немає видач"),
    "no_printer_configured": MessageLookupByLibrary.simpleMessage(
      "Принтер не налаштований, перейдіть до Налаштувань та додайте пристрій",
    ),
    "no_receivals": MessageLookupByLibrary.simpleMessage("Немає прийомів"),
    "no_received_bags": MessageLookupByLibrary.simpleMessage(
      "Немає прийнятих мішків.",
    ),
    "no_returns_selected_date": MessageLookupByLibrary.simpleMessage(
      "Немає повернень для вибраної дати.",
    ),
    "no_returns_today": MessageLookupByLibrary.simpleMessage(
      "Немає повернень на сьогодні",
    ),
    "of_a_box": MessageLookupByLibrary.simpleMessage("колекційна одиниця"),
    "of_all_boxes": MessageLookupByLibrary.simpleMessage(
      "усіх колекційних одиниць?",
    ),
    "ok_name": MessageLookupByLibrary.simpleMessage("OK Оператор Кауційний"),
    "open": MessageLookupByLibrary.simpleMessage("Відкрити"),
    "open_bag": MessageLookupByLibrary.simpleMessage("Мішок відкритий"),
    "open_bags_has_been_fetched": MessageLookupByLibrary.simpleMessage(
      "Відкриті мішки були отримані",
    ),
    "open_bags_list": MessageLookupByLibrary.simpleMessage(
      "Список відкритих мішків",
    ),
    "open_new_bag": MessageLookupByLibrary.simpleMessage(
      "Відкрити новий мішок",
    ),
    "open_new_bag_CAN": MessageLookupByLibrary.simpleMessage(
      "Відкрити новий мішок Пушка",
    ),
    "open_new_bag_plastic": MessageLookupByLibrary.simpleMessage(
      "Відкрити новий мішок Пластик",
    ),
    "open_new_box": MessageLookupByLibrary.simpleMessage(
      "Відкрити нову коробку",
    ),
    "or_enter_bag_number": MessageLookupByLibrary.simpleMessage(
      "або введіть номер мішка",
    ),
    "or_enter_box_number": MessageLookupByLibrary.simpleMessage(
      "або введіть номер коробки",
    ),
    "or_enter_ean": MessageLookupByLibrary.simpleMessage(
      "або введіть номер EAN",
    ),
    "or_enter_label_number": MessageLookupByLibrary.simpleMessage(
      "або введіть номер етикетки",
    ),
    "or_enter_number": MessageLookupByLibrary.simpleMessage(
      "або введіть номер",
    ),
    "or_enter_seal_number": MessageLookupByLibrary.simpleMessage(
      "або введіть номер пломби",
    ),
    "or_search_by_label": MessageLookupByLibrary.simpleMessage(
      "або шукайте за етикеткою",
    ),
    "order_pickup": MessageLookupByLibrary.simpleMessage(
      "Замовлення на вилучення",
    ),
    "package_receival": MessageLookupByLibrary.simpleMessage("Прийом упаковок"),
    "packages_in_bag": MessageLookupByLibrary.simpleMessage(
      "Список упаковок у мішку",
    ),
    "packages_on_the_way": MessageLookupByLibrary.simpleMessage(
      "Упаковки в дорозі",
    ),
    "packages_receival_confirmation": MessageLookupByLibrary.simpleMessage(
      "Підтверджено прийом упаковок",
    ),
    "packages_receival_confirmation_duplicates":
        MessageLookupByLibrary.simpleMessage(
          "Підтверджено прийняття упаковок. Інформація: Деякі мішки у цьому прийманні вже були відскановані раніше. Система розпізнає їх як одну операцію і не вимагає додаткових дій.",
        ),
    "packages_return": MessageLookupByLibrary.simpleMessage(
      "Повернення упаковок",
    ),
    "partially_received": MessageLookupByLibrary.simpleMessage(
      "Частково прийнятий",
    ),
    "pet_quantity": MessageLookupByLibrary.simpleMessage(
      "Пластикові пляшки (шт.):",
    ),
    "pickup": MessageLookupByLibrary.simpleMessage("Забір"),
    "pickup_confirmation_printed_again": MessageLookupByLibrary.simpleMessage(
      "Документ, що підтверджує видачу, був повторно надрукований.",
    ),
    "pickup_confirmation_subtitle": MessageLookupByLibrary.simpleMessage(
      "Одночасно буде надруковано дві копії підтвердження видачі. Підпишіть їх і передайте водієві!",
    ),
    "pickup_confirmed": MessageLookupByLibrary.simpleMessage(
      "Підтверджено видачу водію",
    ),
    "pickup_confirmed_with_print_error": MessageLookupByLibrary.simpleMessage(
      "Підтверджено видачу водію.\nВиникла помилка під час друку документа. Спробуйте ще раз, перейшовши до деталей видачі.",
    ),
    "pickup_not_found": MessageLookupByLibrary.simpleMessage(
      "Не знайдено видачу із зазначеним id",
    ),
    "pickup_summary": MessageLookupByLibrary.simpleMessage("Підсумок видачі"),
    "pickups": MessageLookupByLibrary.simpleMessage("Видачі"),
    "pickups_overview": MessageLookupByLibrary.simpleMessage("Огляд видач"),
    "pieces": MessageLookupByLibrary.simpleMessage("Штуки"),
    "planned_receival": MessageLookupByLibrary.simpleMessage(
      "Заплановані прийоми",
    ),
    "plastic": MessageLookupByLibrary.simpleMessage("Пластик"),
    "pln_return_sum": MessageLookupByLibrary.simpleMessage(
      "Сума повернення PLN",
    ),
    "pln_sum": MessageLookupByLibrary.simpleMessage("Сума PLN"),
    "print_pickup_confirmation": MessageLookupByLibrary.simpleMessage(
      "Друкувати підтвердження видачі",
    ),
    "print_voucher": MessageLookupByLibrary.simpleMessage("Друкувати чек"),
    "print_voucher_for_client": MessageLookupByLibrary.simpleMessage(
      "Друкувати чек для клієнта",
    ),
    "printer_bluetooth_address_not_valid_error_message":
        MessageLookupByLibrary.simpleMessage(
          "Помилка конфігурації принтера – переконайтеся, що вибраний принтер налаштовано правильно.",
        ),
    "printer_bluetooth_not_turned_on_error_message":
        MessageLookupByLibrary.simpleMessage(
          "Помилка друку: немає з\'єднання з принтером. Перевірте, чи увімкнено Bluetooth, і спробуйте ще раз.",
        ),
    "printer_config": MessageLookupByLibrary.simpleMessage(
      "Налаштування принтера",
    ),
    "printer_not_turned_on_error_message": MessageLookupByLibrary.simpleMessage(
      "Помилка друку: переконайтеся, що принтер увімкнено та правильно підключено.",
    ),
    "printer_was_chosen": m3,
    "properly_opened": MessageLookupByLibrary.simpleMessage(
      "відкрито правильно",
    ),
    "quantity_less_or_equal_zero": MessageLookupByLibrary.simpleMessage(
      "Кількість має бути більшою за нуль.",
    ),
    "reason_for_voucher_print_cancelation":
        MessageLookupByLibrary.simpleMessage(
          "Виберіть причину скасування друку ваучера:",
        ),
    "reason_invalid": MessageLookupByLibrary.simpleMessage(
      "Невірна причина зміни пломби / етикетки",
    ),
    "receival": MessageLookupByLibrary.simpleMessage("Прийом"),
    "receival_summary": MessageLookupByLibrary.simpleMessage(
      "Підсумок прийому",
    ),
    "receival_tally": MessageLookupByLibrary.simpleMessage("Огляд прийомів"),
    "received_in_cc": MessageLookupByLibrary.simpleMessage("Прийнятий у CC"),
    "refresh_remote_config": MessageLookupByLibrary.simpleMessage(
      "Оновити віддалену конфігурацію",
    ),
    "reject": MessageLookupByLibrary.simpleMessage("Відхилити"),
    "reject_return": MessageLookupByLibrary.simpleMessage(
      "Відхилити повернення",
    ),
    "released": MessageLookupByLibrary.simpleMessage("Видано водієві"),
    "remove": MessageLookupByLibrary.simpleMessage("Видалити"),
    "removed_last_printer": MessageLookupByLibrary.simpleMessage(
      "Останній принтер було видалено",
    ),
    "reprint_voucher_confirmation": MessageLookupByLibrary.simpleMessage(
      "Ваучер був надрукований",
    ),
    "return_closed_print_voucher": MessageLookupByLibrary.simpleMessage(
      "Повернення закрите. Надрукуйте чек.",
    ),
    "return_closed_show_voucher": MessageLookupByLibrary.simpleMessage(
      "Повернення закрито. Показати ваучер.",
    ),
    "return_deposing_packages": MessageLookupByLibrary.simpleMessage(
      "Повернення депозитних упаковок",
    ),
    "return_finish_confirmation": MessageLookupByLibrary.simpleMessage(
      "Підтвердження завершення повернення",
    ),
    "return_glass_bottles": MessageLookupByLibrary.simpleMessage(
      "Повернення тари: Скло",
    ),
    "return_glass_bottles_title": MessageLookupByLibrary.simpleMessage(
      "Повернення скляної тари",
    ),
    "return_plastics_cans": MessageLookupByLibrary.simpleMessage(
      "Повернення тари: Пластик, Бляшанка",
    ),
    "return_summary": MessageLookupByLibrary.simpleMessage("Резюме повернення"),
    "return_text": MessageLookupByLibrary.simpleMessage("Повернення"),
    "returning_packages_list": MessageLookupByLibrary.simpleMessage(
      "Список повернених упаковок",
    ),
    "returns_archive": MessageLookupByLibrary.simpleMessage("Архів повернень"),
    "saturday_short": MessageLookupByLibrary.simpleMessage("Сб"),
    "scan_bag_code": MessageLookupByLibrary.simpleMessage(
      "Проскануйте код мішка",
    ),
    "scan_bag_seal_code": MessageLookupByLibrary.simpleMessage(
      "Скануйте код пломби мішка",
    ),
    "scan_bag_seal_code_pickup": MessageLookupByLibrary.simpleMessage(
      "Скануйте код пломби мішка та додайте мішок до видачі",
    ),
    "scan_box_label_or_pick_from_list": MessageLookupByLibrary.simpleMessage(
      "Проскануйте код коробки, виберіть зі списку",
    ),
    "scan_new_bag": MessageLookupByLibrary.simpleMessage(
      "Проскануйте код нового мішка",
    ),
    "scan_new_bag_label_code": MessageLookupByLibrary.simpleMessage(
      "Скануйте код нової етикетки мішка",
    ),
    "scan_new_box": MessageLookupByLibrary.simpleMessage(
      "Проскануйте код нової коробки",
    ),
    "scan_new_printer_code": MessageLookupByLibrary.simpleMessage(
      "Проскануйте код нового принтера",
    ),
    "scan_new_seal": MessageLookupByLibrary.simpleMessage(
      "Скануйте нову пломбу",
    ),
    "scan_new_seal_code": MessageLookupByLibrary.simpleMessage(
      "Скануйте код нової пломби",
    ),
    "scan_or_pick_bag_number": MessageLookupByLibrary.simpleMessage(
      "Проскануйте код мішка, виберіть зі списку",
    ),
    "scan_package_ean": MessageLookupByLibrary.simpleMessage(
      "Проскануйте EAN упаковки",
    ),
    "scan_seal": MessageLookupByLibrary.simpleMessage("Проскануйте код пломби"),
    "scan_seal_and_add_bag_to_pickup": MessageLookupByLibrary.simpleMessage(
      "Скануйте код пломби мішка \nі додайте мішок до видачі",
    ),
    "scan_seal_and_add_bag_to_receival": MessageLookupByLibrary.simpleMessage(
      "Скануйте код пломби мішка \nі додайте мішок до прийому",
    ),
    "scan_seal_or_pick_from_list": MessageLookupByLibrary.simpleMessage(
      "Скануйте код пломби, виберіть зі списку",
    ),
    "scanned_package_must_be_assigned_to_bag":
        MessageLookupByLibrary.simpleMessage(
          "Відскановану упаковку потрібно призначити до мішка.",
        ),
    "scanned_package_of_not_allowed_type": MessageLookupByLibrary.simpleMessage(
      "Відсканований тип упаковки не підтримується у вашому пункті збору.",
    ),
    "scanned_package_requires_bag_change": MessageLookupByLibrary.simpleMessage(
      "Відсканована упаковка вимагає зміни мішка.",
    ),
    "seal": MessageLookupByLibrary.simpleMessage("Пломба"),
    "seal_added_successfully": MessageLookupByLibrary.simpleMessage(
      "Мішок було опломбовано.",
    ),
    "seal_already_exists": MessageLookupByLibrary.simpleMessage(
      "Пломба з вказаним номером вже існує",
    ),
    "seal_another_bag": MessageLookupByLibrary.simpleMessage(
      "Залишити пломбу на іншому мішку",
    ),
    "seal_bag": MessageLookupByLibrary.simpleMessage("Опломбувати мішок"),
    "seal_changed_succesfully": MessageLookupByLibrary.simpleMessage(
      "Пломба змінена успішно.",
    ),
    "seal_empty": MessageLookupByLibrary.simpleMessage(
      "Номер пломби не може бути порожнім",
    ),
    "seal_number": MessageLookupByLibrary.simpleMessage("Номер пломби"),
    "seal_scan_success": MessageLookupByLibrary.simpleMessage(
      "Пломба успішно відсканована",
    ),
    "seal_was_added_successfully": MessageLookupByLibrary.simpleMessage(
      "Пломба була успішно додана.",
    ),
    "sealed": MessageLookupByLibrary.simpleMessage("Запломбований"),
    "sealed_bag": MessageLookupByLibrary.simpleMessage("Мішок опломбовано"),
    "sealed_bags_list": MessageLookupByLibrary.simpleMessage(
      "Список опломбованих мішків",
    ),
    "security_deposit_voucher": MessageLookupByLibrary.simpleMessage(
      "Заставний ваучер",
    ),
    "select_all": MessageLookupByLibrary.simpleMessage("Оберіть усі"),
    "selected_bags": MessageLookupByLibrary.simpleMessage("Вибрані сумки"),
    "selected_day": m4,
    "sent_bags": MessageLookupByLibrary.simpleMessage("Відправлені мішки"),
    "server_error": MessageLookupByLibrary.simpleMessage(
      "Помилка сервера. Будь ласка, спробуйте пізніше.",
    ),
    "session_expired": MessageLookupByLibrary.simpleMessage(
      "Сесія завершена, увійдіть знову",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Налаштування"),
    "show_voucher": MessageLookupByLibrary.simpleMessage("Показати ваучер"),
    "submit_boxes_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Подати коробки на вилучення",
    ),
    "submitted_for_pickup": MessageLookupByLibrary.simpleMessage(
      "Подано на вилучення",
    ),
    "summary": MessageLookupByLibrary.simpleMessage("Підсумок"),
    "sunday_short": MessageLookupByLibrary.simpleMessage("Нд"),
    "technical_issue": MessageLookupByLibrary.simpleMessage(
      "Технічна проблема",
    ),
    "terms_and_condition_paragraph_1": MessageLookupByLibrary.simpleMessage(
      "I. Вступ: Наше зобов\'язання щодо захисту даних наших користувачів",
    ),
    "terms_and_conditions_part_1": MessageLookupByLibrary.simpleMessage(
      "У сучасному цифровому світі, де дані стали ключовим ресурсом, OK OPERATOR KAUCYJNY S.A. визнає захист персональних даних як фундаментальний елемент нашої діяльності. Ми глибоко переконані, що довіра осіб, які користуються наданими нами послугами, а також наших контрагентів є не лише привілеєм, але й зобов\'язанням, яке ми сприймаємо з найвищою серйозністю.",
    ),
    "terms_and_conditions_part_2": MessageLookupByLibrary.simpleMessage(
      "Наша компанія, що працює в галузі застави, усвідомлює, що ефективний захист персональних даних є ключовим для підтримання цілісності наших бізнес-процесів, побудови довгострокових відносин з партнерами та забезпечення відповідності чинному законодавству. Тому захист персональних даних для нас є не лише правовим обов\'язком, але й невід\'ємною частиною нашої організаційної культури та бізнес-етики.",
    ),
    "terms_and_conditions_part_3": MessageLookupByLibrary.simpleMessage(
      "В OK OPERATOR KAUCYJNY S.A. ми віримо, що прозорість у сфері обробки персональних даних є основою довіри в бізнес-відносинах. Тому ми докладаємо всіх зусиль, щоб забезпечити нашим партнерам та клієнтам повну прозорість щодо того, як ми збираємо, обробляємо та захищаємо їхні персональні дані. Наша політика конфіденційності є вираженням цього зобов\'язання – вона становить комплексний путівник по наших практиках захисту даних.",
    ),
    "terms_and_conditions_part_4": MessageLookupByLibrary.simpleMessage(
      "Ми інвестуємо значні кошти в найсучасніші технологічні та організаційні рішення, щоб гарантувати найвищий рівень безпеки довірених нам даних. Ми регулярно проводимо аудити та оновлення наших систем, щоб відповідати постійно еволюціонуючим загрозам у кіберпросторі. Водночас ми проводимо постійне навчання наших співробітників, щоб вони мали повне розуміння важливості захисту персональних даних та знали найкращі практики в цій сфері.",
    ),
    "terms_and_conditions_part_5": MessageLookupByLibrary.simpleMessage(
      "Ми розуміємо, що в динамічному бізнес-середовищі ефективний обмін інформацією є ключовим для успіху. Тому, піклуючись про захист даних, ми прагнемо одночасно забезпечити нашим партнерам та клієнтам плавність бізнес-процесів. Наша політика конфіденційності побудована таким чином, щоб забезпечити ефективну співпрацю при збереженні найвищих стандартів захисту даних.",
    ),
    "terms_and_conditions_part_6": MessageLookupByLibrary.simpleMessage(
      "В OK OPERATOR KAUCYJNY S.A. ми переконані, що відповідальне управління персональними даними є не лише правовим обов\'язком, але й ключовим фактором, що будує довіру та лояльність наших бізнес-партнерів і клієнтів. Тому ми зобов\'язуємося постійно вдосконалювати наші практики захисту даних, адаптуватися до мінливих правових і технологічних реалій та вести відкритий діалог з нашими зацікавленими сторонами з питань конфіденційності даних.",
    ),
    "terms_and_conditions_part_7": MessageLookupByLibrary.simpleMessage(
      "Запрошуємо ознайомитися з нашою детальною політикою конфіденційності, яка є відображенням нашого зобов\'язання щодо захисту ваших персональних даних. Ми переконані, що завдяки цим діям ми будуємо не лише безпечні, але й тривалі бізнес-відносини, засновані на взаємній довірі та повазі до конфіденційності.",
    ),
    "terms_and_conditions_title": MessageLookupByLibrary.simpleMessage(
      "Регламент мобільного додатку OK",
    ),
    "test_application_insights": MessageLookupByLibrary.simpleMessage(
      "Test Application Insights",
    ),
    "thursday_short": MessageLookupByLibrary.simpleMessage("Чт"),
    "token_not_provided": MessageLookupByLibrary.simpleMessage(
      "Токен не надано",
    ),
    "torn_bag": MessageLookupByLibrary.simpleMessage("Розірваний мішок"),
    "torn_box": MessageLookupByLibrary.simpleMessage("Пошкоджена коробка"),
    "total_quantity": MessageLookupByLibrary.simpleMessage("Загалом:"),
    "tuesday_short": MessageLookupByLibrary.simpleMessage("Вт"),
    "type_invalid": MessageLookupByLibrary.simpleMessage("Невірний тип мішка"),
    "type_not_found": MessageLookupByLibrary.simpleMessage(
      "Не знайдено вказаний тип мішка",
    ),
    "unknown_ean_code": MessageLookupByLibrary.simpleMessage(
      "Невідомий код EAN",
    ),
    "unreadable_label": MessageLookupByLibrary.simpleMessage(
      "Нечитабельна етикетка",
    ),
    "unreadable_seal": MessageLookupByLibrary.simpleMessage(
      "Нечитабельна пломба",
    ),
    "user_not_authorized": MessageLookupByLibrary.simpleMessage(
      "У вас немає прав доступу до цієї дії",
    ),
    "voucher_generation_date": MessageLookupByLibrary.simpleMessage(
      "Дата генерації ваучера",
    ),
    "voucher_issuance": MessageLookupByLibrary.simpleMessage("Видача ваучера"),
    "voucher_printed_for_client": MessageLookupByLibrary.simpleMessage(
      "Чек надруковано.",
    ),
    "wednesday_short": MessageLookupByLibrary.simpleMessage("Ср"),
    "welcome_to_system": MessageLookupByLibrary.simpleMessage(
      "Вітаємо в системі",
    ),
    "wrong_device_to_cc": MessageLookupByLibrary.simpleMessage(
      "Неправильне прив’язання пристрою до центру підрахунку.",
    ),
    "wrong_device_to_collection_point": MessageLookupByLibrary.simpleMessage(
      "Неправильне прив’язання пристрою до пункту збору.",
    ),
    "wrong_device_to_retail_chain": MessageLookupByLibrary.simpleMessage(
      "Неправильне прив’язання пристрою до торговельної мережі.",
    ),
    "wrong_package_type": MessageLookupByLibrary.simpleMessage(
      "Просканована упаковка не є упаковкою",
    ),
    "wrong_user_configuration": MessageLookupByLibrary.simpleMessage(
      "Користувач налаштований некоректно.",
    ),
    "wrong_user_to_cc": MessageLookupByLibrary.simpleMessage(
      "Неправильне прив’язання користувача до центру підрахунку.",
    ),
    "wrong_user_to_collection_point": MessageLookupByLibrary.simpleMessage(
      "Неправильне прив’язання користувача до пункту збору.",
    ),
    "wrong_user_to_retail_chain": MessageLookupByLibrary.simpleMessage(
      "Неправильне прив’язання користувача до торговельної мережі.",
    ),
  };
}
