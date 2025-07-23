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
      'welcome_permissions_intro': 'Welcome to Beenai Sense. To use the camera and microphone, please tap anywhere on the screen to grant access.',
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

      // Permissions screen
      'thank_you_permissions_granted': 'Thank you. Permissions granted. Loading the app.',
      'permissions_permanently_denied': 'Permissions are permanently denied. Opening app settings.',
      'permissions_denied': 'Permissions denied. Please try again.',
      'beenai_sense_requires_camera_and_microphone_access': 'Beenai Sense requires camera and microphone access.',

      // Instruction dialog
      'How to use BeenAI Sense': 'How to use BeenAI Sense',
      'Welcome to BeenAI Sense!\n\nThis app is designed to help you with:\n• Object Detection - Identifies objects around you\n• OCR - Reads text from images or camera\n• BeenAI Sense - Voice assistant for general information\n• Currency Reader - Identifies currency notes\n• Settings - Customize app preferences\n\nNavigation Instructions:\n• Swipe left/right to switch between sections\n• Single tap on this dialog to close it\n• Double tap on this dialog to replay instructions': 'Welcome to BeenAI Sense!\n\nThis app is designed to help you with:\n• Object Detection - Identifies objects around you\n• OCR - Reads text from images or camera\n• BeenAI Sense - Voice assistant for general information\n• Currency Reader - Identifies currency notes\n• Settings - Customize app preferences\n\nNavigation Instructions:\n• Swipe left/right to switch between sections\n• Single tap on this dialog to close it\n• Double tap on this dialog to replay instructions',
      'Single tap to close - Double tap to repeat instructions': 'Single tap to close - Double tap to repeat instructions',
      'Welcome to BeenAI Sense!\n\nThis app helps you with object detection, text reading, voice assistance, currency identification, and settings management.\n\nTo navigate, swipe left or right to move between different sections. \nSingle tap on this instruction to close it. \nDouble tap to replay these instructions.\nOn main screens, double tap to activate the current feature.\n\nThank you for using BeenAI Sense!': 'Welcome to BeenAI Sense!\n\nThis app helps you with object detection, text reading, voice assistance, currency identification, and settings management.\n\nTo navigate, swipe left or right to move between different sections. \nSingle tap on this instruction to close it. \nDouble tap to replay these instructions.\nOn main screens, double tap to activate the current feature.\n\nThank you for using BeenAI Sense!',
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
      'welcome_permissions_intro': 'بینائی سینس میں خوش آمدید۔ کیمرے اور مائکروفون استعمال کرنے کے لیے، براہ کرم اجازت دینے کے لیے اسکرین پر کہیں بھی ٹیپ کریں۔',
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

      // Permissions screen
      'thank_you_permissions_granted': 'شکریہ۔ اجازتیں حاصل ہوئی۔ ایپ لوڈ ہو رہا ہے۔',
      'permissions_permanently_denied': 'اجازتیں مستقل طور پر مسترد کر دی گئی ہیں۔ سیٹنگز کو تبدیل کرنے کے لیے ایپ کی سیٹنگز میں جائیں۔',
      'permissions_denied': 'اجازتیں رد کر دی گئی ہیں۔ براہ کرم دوبارہ کوشش کریں۔',
      'beenai_sense_requires_camera_and_microphone_access': 'بینائی سینس کو کیمرے اور مائکروفون کی ضرورت ہے۔',
      
      // Instruction dialog
      'How to use BeenAI Sense': 'بینائی سینس کو استعمال کرنے کا طریقہ',
      'Welcome to BeenAI Sense!\n\nThis app is designed to help you with:\n• Object Detection - Identifies objects around you\n• OCR - Reads text from images or camera\n• BeenAI Sense - Voice assistant for general information\n• Currency Reader - Identifies currency notes\n• Settings - Customize app preferences\n\nNavigation Instructions:\n• Swipe left/right to switch between sections\n• Single tap on this dialog to close it\n• Double tap on this dialog to replay instructions': 'بینائی سینس میں خوش آمدید!\n\nیہ ایپ آپ کی مدد کرتی ہے:\n• اشیاء کی شناخت - آپ کے آس پاس کی چیزوں کی شناخت کرتا ہے\n• متن کی شناخت - تصاویر یا کیمرے سے متن پڑھتا ہے\n• بینائی سینس - عام معلومات کے لیے آواز سے مدد\n• کرنسی ریڈر - کرنسی نوٹوں کی شناخت\n• ترتیبات - ایپ کی ترجیحات کو تبدیل کریں\n\nنیویگیشن کے ہدایات:\n• سیکشنز کے درمیان سوئچ کرنے کے لیے بائیں/دائیں سوائپ کریں\n• اس ڈائیلاگ کو بند کرنے کے لیے ایک بار ٹیپ کریں\n• ہدایات کو دوبارہ سننے کے لیے ڈبل ٹیپ کریں',
      'Single tap to close - Double tap to repeat instructions': 'بند کرنے کے لیے ایک بار ٹیپ - ہدایات دوبارہ سننے کے لیے ڈبل ٹیپ',
      'Welcome to BeenAI Sense!\n\nThis app helps you with object detection, text reading, voice assistance, currency identification, and settings management.\n\nTo navigate, swipe left or right to move between different sections. \nSingle tap on this instruction to close it. \nDouble tap to replay these instructions.\n\nThank you for using BeenAI Sense!': 'بینائی سینس میں خوش آمدید!\n\nیہ ایپ آپ کی مدد کرتی ہے اشیاء کی شناخت، متن پڑھنے، آواز سے مدد، کرنسی کی شناخت، اور سیٹنگز کے انتظام میں۔\n\nنیویگیٹ کرنے کے لیے، مختلف سیکشنز کے درمیان جانے کے لیے بائیں یا دائیں سوائپ کریں۔\nاس ہدایت کو بند کرنے کے لیے ایک بار ٹیپ کریں۔\nان ہدایات کو دوبارہ سننے کے لیے ڈبل ٹیپ کریں۔\n\nبینائی سینس کا استعمال کرنے کا شکریہ!',
    },
  };
}
