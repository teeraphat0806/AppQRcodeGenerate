import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QRDetailScreen extends StatefulWidget {
  final Map<String, dynamic> qrData;
  const QRDetailScreen({super.key, required this.qrData});

  @override
  State<QRDetailScreen> createState() => _QRDetailScreenState();
}

class _QRDetailScreenState extends State<QRDetailScreen> {
  final supabase = Supabase.instance.client;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.qrData['Favourite'] ?? false;
  }

  Future<void> toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    await supabase.from('qrcode').update({'Favourite': isFavorite}).eq('id', widget.qrData['id']);
  }

  Future<void> deleteQRCode() async {
    try {
      await supabase.from('qrcode').delete().eq('id', widget.qrData['id']);
      print("✅ ลบสำเร็จ");
      if (mounted) {
        Navigator.pop(context, true); // ✅ ส่งค่า `true` กลับไปบอกว่ามีการลบ
      }
    } catch (e) {
      print("❌ ลบไม่สำเร็จ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String qrValue = widget.qrData['qrcode'].toString();
    String name = widget.qrData['name'] ?? "QR Code";
    // ✅ ใช้ Regular Expression ดึงเฉพาะตัวเลข
    RegExp regex = RegExp(r'\d+');
    Iterable<Match> matches = regex.allMatches(qrValue);

    // ✅ แปลงผลลัพธ์เป็น String โดยคั่นด้วย " "
    String result = matches.map((match) => match.group(0)!).join(" ");
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: () async {
              await deleteQRCode();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrValue,
              size: 250,
            ),
            const SizedBox(height: 20),
            Text(
              qrValue.contains('paycontroller')?
              "PromptPay \n $result":"Link/Text \t $result",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
