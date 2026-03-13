// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get sales => 'Sales';

  @override
  String get purchase => 'Purchase';

  @override
  String get inventory => 'Inventory';

  @override
  String get accounts => 'Accounts';

  @override
  String get hr => 'HR & Payroll';

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome back';

  @override
  String get welcomeSubtitle => 'Here is what\'s happening today';

  @override
  String get quickLinks => 'Quick Links';

  @override
  String get summary => 'Summary';

  @override
  String get noRecordsFound => 'No records found';

  @override
  String get modified => 'Modified';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get serverConfig => 'Server Configuration';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get openLeads => 'Open Leads';

  @override
  String get comments => 'Comments & Activity';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get noActivity => 'No activity yet.';

  @override
  String newDoc(String doctype) {
    return 'New $doctype';
  }
}
