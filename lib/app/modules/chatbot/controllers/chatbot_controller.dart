import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:beenai_sense/Utility/language_helper.dart';
import 'package:beenai_sense/Utility/tts_helper.dart';
import 'package:beenai_sense/Utility/chat_service.dart';
import 'package:beenai_sense/Utility/intent_helper.dart';


class ChatbotController extends GetxController {

  // STT state
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxBool isListening = false.obs;
  final RxString partialText = ''.obs;

  // Busy state for network calls
  final RxBool isBusy = false.obs;

  // Cache current language code
  String _languageCode = 'en-US';

  @override
  void onInit() {
    super.onInit();
    _initLanguage();
    _warmupTTS();
  }

  Future<void> _initLanguage() async {
    try {
      _languageCode = await LanguageHelper().getCurrentLanguageCode();
    } catch (_) {
      _languageCode = 'en-US';
    }
  }

  Future<void> _warmupTTS() async {
    await TTSHelper.initTTS();
  }

  Future<void> startListening() async {
    if (isListening.value) return;

    await _initLanguage();

    final available = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          isListening.value = false;
        }
      },
      onError: (e) {
        isListening.value = false;
        _notifyError(_loc('Mic error. Please try again.', 'مائیک کی خرابی۔ دوبارہ کوشش کریں۔'));
      },
    );

    if (!available) {
      _notifyError(_loc('Speech recognition not available.', 'تقریر کی شناخت دستیاب نہیں۔'));
      return;
    }

    partialText.value = '';
    isListening.value = true;
    await _speech.listen(
      localeId: _languageCode,
      onResult: (r) async {
        partialText.value = r.recognizedWords;
        if (r.finalResult && partialText.isNotEmpty) {
          await _handleUserQuery(partialText.value);
          await stopListening();
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    if (!isListening.value) return;
    await _speech.stop();
    isListening.value = false;
  }

  Future<void> _handleUserQuery(String text) async {

  // --- Step 1: Try Gemini-based advanced intent detection first ---
  bool handled = false;
  try {
    print('Gemini intent detection: $text');
    handled = await IntentHelper.tryHandleIntent(
      text,
      languageCode: _languageCode,
    );
    print('Intent detection result: $handled');
  } catch (e) {
    print('Intent detection error: $e');
  }

  if (handled) {
    final resp = _loc('Opening...', 'کھولا جا رہا ہے...');
    await _speak(resp);
    return;
  }

  // --- Step 2: No intent? Send to chat service ---
  isBusy.value = true;
  try {
    final reply = await ChatService.chat(
      prompt: text,
      languageCode: _languageCode,
      history: [],
    );
    await _speak(reply);
  } catch (e) {
    print(e);
    final err = _loc('Sorry, I had trouble answering.', 'معذرت، جواب دینے میں مشکل پیش آئی۔');
    _notifyError(err);
    await _speak(err);
  } finally {
    isBusy.value = false;
  }
}


  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    await _handleUserQuery(text.trim());
  }

 final RxBool isSpeaking = false.obs;

Future<void> stopSpeaking() async {
  await TTSHelper.stop();
  isSpeaking.value = false;
}


Future<void> _speak(String text) async {
  try {
    await TTSHelper.setLanguage(_languageCode);
    isSpeaking.value = true;
    await TTSHelper.speak(text);
    isSpeaking.value = false;
  } catch (_) {
    isSpeaking.value = false;
  }
}


  String _loc(String en, String ur) => _languageCode == 'ur-PK' ? ur : en;

  void _notifyError(String message) {
    final title = _loc('Error', 'خرابی');
    // Using Get.snackbar for non-blocking feedback
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
  }
}
