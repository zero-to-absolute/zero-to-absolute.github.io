import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://zbptxyjdkybngjnvmygx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpicHR4eWpka3libmdqbnZteWd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwOTUxNjYsImV4cCI6MjA3NTY3MTE2Nn0.Z-AGcUCqURdQGNMKLSJCSyD9bDMUrqcPX-eBeuZ2s2w';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}