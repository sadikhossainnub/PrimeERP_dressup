// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get dashboard => 'ড্যাশবোর্ড';

  @override
  String get sales => 'বিক্রয়';

  @override
  String get purchase => 'ক্রয়';

  @override
  String get inventory => 'ইনভেন্টরি';

  @override
  String get accounts => 'অ্যাকাউন্টস';

  @override
  String get hr => 'এইচআর ও পে-রোল';

  @override
  String get logout => 'লগ আউট';

  @override
  String get welcome => 'স্বাগতম';

  @override
  String get welcomeSubtitle => 'আজকের আপডেট এখানে দেখুন';

  @override
  String get quickLinks => 'কুইক লিঙ্ক';

  @override
  String get summary => 'সারাংশ';

  @override
  String get noRecordsFound => 'কোন তথ্য পাওয়া যায়নি';

  @override
  String get modified => 'পরিবর্তিত';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get username => 'ব্যবহারকারীর নাম';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get login => 'লগইন';

  @override
  String get serverConfig => 'সার্ভার কনফিগারেশন';

  @override
  String get totalSales => 'মোট বিক্রয়';

  @override
  String get openLeads => 'নতুন লিড';

  @override
  String get comments => 'মন্তব্য ও কার্যক্রম';

  @override
  String get addComment => 'একটি মন্তব্য লিখুন...';

  @override
  String get noActivity => 'এখনো কোন কার্যক্রম নেই।';

  @override
  String newDoc(String doctype) {
    return 'নতুন $doctype';
  }
}
