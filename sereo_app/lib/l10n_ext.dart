import 'package:flutter/widgets.dart';
import 'package:sereo_app/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this)!;
}
