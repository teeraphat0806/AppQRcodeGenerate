import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
Future<List<Map<String, dynamic>>> fetchUserQRCodes() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    print("❌ ไม่มีผู้ใช้ล็อกอิน");
    return [];
  }

  final response = await supabase
      .from('qrcode')
      .select()
      .eq('auth_uid', user.id); // ✅ ดึงเฉพาะของ auth_uid ปัจจุบัน

  if (response == null) {
    print("❌ ไม่พบข้อมูล");
    return [];
  }

  print("✅ ข้อมูลของผู้ใช้: $response");
  return List<Map<String, dynamic>>.from(response);
}
Future<List<Map<String, dynamic>>> fetchFavouriteQRCodes() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    print("❌ ไม่มีผู้ใช้ล็อกอิน");
    return [];
  }

  final response = await supabase
      .from('qrcode')
      .select()
      .eq('auth_uid', user.id)
      .eq('Favourite',true); // ✅ ดึงเฉพาะของ auth_uid ปัจจุบัน

  if (response == null) {
    print("❌ ไม่พบข้อมูล");
    return [];
  }

  print("✅ ข้อมูลของผู้ใช้: $response");
  return List<Map<String, dynamic>>.from(response);
}
Future<List<Map<String, dynamic>>> fetchNotFavouriteQRCodes() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    print("❌ ไม่มีผู้ใช้ล็อกอิน");
    return [];
  }

  final response = await supabase
      .from('qrcode')
      .select()
      .eq('auth_uid', user.id)
      .neq('Favourite',true); // ✅ ดึงเฉพาะของ auth_uid ปัจจุบัน

  if (response == null) {
    print("❌ ไม่พบข้อมูล");
    return [];
  }

  print("✅ ข้อมูลของผู้ใช้: $response");
  return List<Map<String, dynamic>>.from(response);
}
