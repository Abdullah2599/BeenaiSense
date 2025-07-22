import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      // General
      'app_name': 'Beenai Sense',
      'welcome': 'Welcome to Beenai Sense',
      'select_language': 'Select your preferred language',

      // Navigation
      'home': 'Home',
      'ocr': 'Text Recognition',
      'object_detection': 'Object Detection',

      // Home screen
      'welcome_message': 'Welcome to Beenai Sense',
      'tap_for_ocr': 'Tap left for text recognition',
      'tap_for_object': 'Tap right for object detection',
      'tap_for_help': 'Tap center for help',
      'help_message':
          'This app helps visually impaired users with text recognition and object detection. Swipe or tap to navigate.',

      // OCR screen
      'ocr_instructions': 'Point camera at text and tap to capture',
      'text_detected': 'Text detected',
      'no_text': 'No text detected',
      'reading': 'Reading...',  
      'hold_anywhere': 'Hold anywhere on screen to read',  

      // Object detection screen
      'object_instructions': 'Point camera at objects to identify',
      'detected_object': 'Detected: ',
      'no_object': 'No objects detected',

      // Bottomnav screen
      'currency_reader': 'Currency Reader',
      'settings': 'Settings',
      'beenai_sense': 'Beenai Sense',


    },
    'ur_PK': {
      // General
      'app_name': 'بینائی سینس',
      'welcome': 'بینائی سینس میں خوش آمدید',
      'select_language': 'اپنی پسندیدہ زبان منتخب کریں',

      // Navigation
      'home': 'ہوم',
      'ocr': 'لکھائی کی شناخت',
      'object_detection': 'اشیاء کی شناخت',

      // Home screen
      'welcome_message': 'بینائی سینس میں خوش آمدید',
      'tap_for_ocr': 'متن کی شناخت کے لیے بائیں طرف ٹیپ کریں',
      'tap_for_object': 'اشیاء کی شناخت کے لیے دائیں طرف ٹیپ کریں',
      'tap_for_help': 'مدد کے لیے درمیان میں ٹیپ کریں',
      'help_message':
          'یہ ایپ بصری معذور صارفین کو متن کی شناخت اور اشیاء کی شناخت میں مدد کرتی ہے۔ نیویگیٹ کرنے کے لیے سوائپ یا ٹیپ کریں۔',

      // OCR screen
      'ocr_instructions':
          'کیمرے کو متن کی طرف رکھیں اور تصویر لینے کے لیے ٹیپ کریں',
      'text_detected': 'متن شناخت ہوا',
      'no_text': 'کوئی متن شناخت نہیں ہوا',  
      'reading': 'پڑھا جا رہا ہے...',
      'hold_anywhere': 'اسکرین پر کہیں بھی تھام کر پڑھیں',

      // Object detection screen
      'object_instructions': 'اشیاء کی شناخت کے لیے کیمرے کو ان کی طرف رکھیں',
      'detected_object': 'شناخت شدہ: ',
      'no_object': 'کوئی اشیاء شناخت نہیں ہوئی',

      // Bottomnav screen
      'currency_reader': 'کرنسی کی شناخت',
      'settings': 'آپشنز',
      'beenai_sense': 'بینائی سینس',
    },
  };
}
