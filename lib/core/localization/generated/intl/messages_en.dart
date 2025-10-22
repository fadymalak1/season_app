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

  static String m0(userName) => "Hello ${userName}!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("Season App"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "dontHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
    "forgetPassword": MessageLookupByLibrary.simpleMessage("Forget Password?"),
    "helloUser": m0,
    "lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "or": MessageLookupByLibrary.simpleMessage("OR"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "startNow": MessageLookupByLibrary.simpleMessage("Start Now"),
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "verifyMail": MessageLookupByLibrary.simpleMessage("Verify Mail"),
    "verifyMailBody": MessageLookupByLibrary.simpleMessage(
      "We have sent a verification code to your email",
    ),
    "welcome": MessageLookupByLibrary.simpleMessage("Welcome!"),
    "welcomeLogin": MessageLookupByLibrary.simpleMessage(
      "Welcome back to SEASON",
    ),
    "welcomeSignUp": MessageLookupByLibrary.simpleMessage(
      "Create your account and get started!",
    ),
    "welcomeText": MessageLookupByLibrary.simpleMessage(
      "Your comprehensive companion for every journey",
    ),
  };
}
