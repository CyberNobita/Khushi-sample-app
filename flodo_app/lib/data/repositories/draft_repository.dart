import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DraftRepository {
  static const _draftKey = 'task_form_draft_v1';

  Future<void> saveDraft(Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return decoded;
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}
