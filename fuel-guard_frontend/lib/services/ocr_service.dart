import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// ইমেজ প্রসেস করে নাম্বার প্লেট এক্সট্রাক্ট করার মেইন ফাংশন
  Future<String?> scanNumberPlate(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) return null;

      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 🔍 আরও শক্তিশালী REGEX (BD Plate Focused)
      // এটি ঢাকা-মেট্রো, চট্ট-মেট্রো বা সরাসরি কোড (যেমন: গ-১১-২২২২) সবকটি ধরবে
      final RegExp plateRegex = RegExp(
        r'([A-Z]{1,10}-?[A-Z]{0,10}-?[A-Z]{0,5}-?\d{2}-?\d{4})|([A-Z]{1,10}-?\d{4,6})',
        caseSensitive: false,
      );

      List<String> candidates = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // ১. ক্লিনআপ (স্পেস রিমুভ এবং আপারকেস)
          String rawText = line.text.toUpperCase().replaceAll(' ', '').trim();

          // ২. OCR এর সাধারণ ভুলগুলো সংশোধন (যেমন: I কে 1 বা O কে 0)
          String sanitizedText = _sanitizeOCR(rawText);

          // ৩. Regex ম্যাচ চেক
          if (plateRegex.hasMatch(sanitizedText)) {
            String? match = plateRegex.firstMatch(sanitizedText)?.group(0);
            if (match != null && match.length > 5) {
              return match; // সরাসরি ম্যাচ পাওয়া গেলে রিটার্ন করবে
            }
          }

          // পটেনশিয়াল ক্যান্ডিডেট লিস্টে রাখা (যদি হাইফেন থাকে)
          if (sanitizedText.contains('-') && sanitizedText.length > 6) {
            candidates.add(sanitizedText);
          }
        }
      }

      // ৪. ফলব্যাক: যদি Regex এ না মেলে তবে হাইফেন যুক্ত বড় টেক্সটটি নিবে
      if (candidates.isNotEmpty) {
        // সবচেয়ে লম্বা টেক্সটটি আগে নেওয়ার চেষ্টা করবে
        candidates.sort((a, b) => b.length.compareTo(a.length));
        return candidates.first;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// OCR এর সাধারণ ভুলগুলো ফিক্স করার লজিক
  String _sanitizeOCR(String input) {
    // সাধারণত বাংলাদেশের প্লেটের শেষ ৪টি ডিজিট নাম্বার হয়
    // তাই শেষের দিকের অক্ষরগুলোকে ডিজিটে রূপান্তর করা নিরাপদ
    if (input.length > 4) {
      String prefix = input.substring(0, input.length - 4);
      String suffix = input.substring(input.length - 4);

      // শুধুমাত্র শেষ ৪ ডিজিটের ভুলগুলো ঠিক করছি
      suffix = suffix
          .replaceAll('O', '0')
          .replaceAll('D', '0')
          .replaceAll('I', '1')
          .replaceAll('L', '1')
          .replaceAll('S', '5')
          .replaceAll('B', '8');

      return prefix + suffix;
    }
    return input;
  }

  void dispose() {
    _textRecognizer.close();
  }
}