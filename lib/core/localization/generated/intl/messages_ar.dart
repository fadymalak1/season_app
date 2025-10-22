// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static String m0(userName) => "أهلاً يا ${userName}!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "لديك حساب بالفعل؟",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("تطبيق سيزون"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage(
      "تأكيد كلمة المرور",
    ),
    "dontHaveAccount": MessageLookupByLibrary.simpleMessage("ليس لديك حساب؟"),
    "email": MessageLookupByLibrary.simpleMessage("البريد الالكتروني"),
    "firstName": MessageLookupByLibrary.simpleMessage("الاسم الأول"),
    "forgetPassword": MessageLookupByLibrary.simpleMessage("نسيت كلمة المرور؟"),
    "helloUser": m0,
    "lastName": MessageLookupByLibrary.simpleMessage("الاسم الأخير"),
    "loading": MessageLookupByLibrary.simpleMessage("جاري التحميل"),
    "login": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "or": MessageLookupByLibrary.simpleMessage("أو"),
    "password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
    "phone": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
    "signUp": MessageLookupByLibrary.simpleMessage("سجل الآن"),
    "startNow": MessageLookupByLibrary.simpleMessage("ابدأ الان"),
    "verify": MessageLookupByLibrary.simpleMessage("تحقق"),
    "verifyMail": MessageLookupByLibrary.simpleMessage(
      "تحقق من البريد الالكتروني",
    ),
    "verifyMailBody": MessageLookupByLibrary.simpleMessage(
      "لقد أرسلنا رمز تحقق مكوّن من 4 أرقام إلى بريدك الإلكتروني",
    ),
    "welcome": MessageLookupByLibrary.simpleMessage("مرحبًا!"),
    "welcomeLogin": MessageLookupByLibrary.simpleMessage(
      "مرحباً بعودتك إلي SEASON",
    ),
    "welcomeSignUp": MessageLookupByLibrary.simpleMessage(
      "أنشئ حسابك وابدأ الآن!",
    ),
    "welcomeText": MessageLookupByLibrary.simpleMessage(
      "رفيقك الشامل في كل رحلة",
    ),
  };
}
