import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HotlineService {
  Future<void> callHotline() async {
    final uri = Uri(scheme: 'tel', path: '0337760280');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Không thể mở ứng dụng gọi điện');
    }
  }
}
