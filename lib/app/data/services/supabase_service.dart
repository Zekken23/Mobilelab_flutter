import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient client;

  Future<SupabaseService> init() async {
    await dotenv.load(fileName: ".env");
    
    await Supabase.initialize(
      url: dotenv.env['https://ilcqvltujdofdaqywequ.supabase.co']!,
      anonKey: dotenv.env['eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlsY3F2bHR1amRvZmRhcXl3ZXF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NjExNTAsImV4cCI6MjA3ODMzNzE1MH0._ahD35q4WFXk_UXP_aM8cnpus-kO3Yd9V9_z-n8rbPU']!,
    );
    
    client = Supabase.instance.client;
    return this;
  }
}