import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient client;

  Future<SupabaseService> init() async {
    await dotenv.load(fileName: ".env");
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    
    client = Supabase.instance.client;
    return this;
  }
}