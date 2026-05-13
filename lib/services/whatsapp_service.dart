import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class WhatsAppService {
  /// Launches WhatsApp with the given phone number
  /// Supports various formats: 03001234567, +923001234567, 923001234567
  static Future<void> launchWhatsApp(String phoneNumber) async {
    try {
      // Clean the phone number
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      // Format for WhatsApp URL (must not have +)
      String formattedNumber = '';

      if (cleanedNumber.startsWith('92')) {
        formattedNumber = cleanedNumber;
      } else if (cleanedNumber.startsWith('0')) {
        formattedNumber = '92${cleanedNumber.substring(1)}';
      } else {
        formattedNumber = '92$cleanedNumber';
      }

      // Try universal first (wa.me)
      final url = Uri.parse('https://wa.me/$formattedNumber');
      
      // Try launching with external application mode first
      try {
        bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (launched) return;
      } catch (e) {
        debugPrint('Direct wa.me launch failed: $e');
      }

      // If that failed, try the direct whatsapp scheme (better for some mobile devices)
      final whatsappSchemeUrl = Uri.parse('whatsapp://send?phone=$formattedNumber');
      if (await canLaunchUrl(whatsappSchemeUrl)) {
        await launchUrl(whatsappSchemeUrl);
        return;
      }

      // Fallback for web or if WhatsApp app is not found/not responding to scheme
      final webUrl = Uri.parse('https://web.whatsapp.com/send?phone=$formattedNumber');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.platformDefault);
      } else {
        // Just try to launch it anyway as a last resort
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      throw Exception('Could not open WhatsApp. Please make sure it is installed.');
    }
  }

  /// Validates if a phone number is in a valid Pakistani format
  static bool isValidPakistaniNumber(String phoneNumber) {
    // Remove all spaces and special characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-()]'), '');

    // Check if it matches Pakistani mobile number format
    return RegExp(r'^(?:\+92|92|0)?3\d{9}$').hasMatch(cleaned);
  }
}
