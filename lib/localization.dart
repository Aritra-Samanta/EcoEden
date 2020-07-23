import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
  }

  static String get appTitle => "Ecoeden";


//   String gameDeleted(String task) => Intl.message(
//     'Deleted "$task"',
//     name: 'gameDeleted',
//     args: [task],
//     locale: locale.toString(),
//   );
// }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  Future<AppLocalizations> load(Locale locale) =>
      Future(() => AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode.toLowerCase().contains("en");
}