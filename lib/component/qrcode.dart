import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;
import 'package:thaiqr/thaiqr.dart';

class QRImage extends StatefulWidget {
  final String initial;
  final TextEditingController controller;
  final TextEditingController paycontroller;
  final TextEditingController name;
  const QRImage(this.initial, this.controller, this.paycontroller, this.name,
      {super.key});

  @override
  State<QRImage> createState() => _QRImageState();
}

class _QRImageState extends State<QRImage> {
  GlobalKey globalKey = GlobalKey(); // ใช้จับภาพ QR Code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == 'ลิงค์ หรือ คำ'
            ? 'QR Code'
            : 'PromptPay QR Code'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.share), onPressed: _shareQRCode), // แชร์
          //   IconButton(icon: const Icon(Icons.save), onPressed: _saveQRCode), // บันทึก
          IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _uploadToSupabase), // อัปโหลด
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: globalKey,
          child: widget.initial == 'ลิงค์ หรือ คำ'
              ? _buildTextQR()
              : _buildPromptPayQR(),
        ),
      ),
    );
  }

  // **📤 1. แชร์ QR Code ไปแอปอื่น**
  Future<void> _shareQRCode() async {
    try {
      File qrFile = await _captureAndSaveTemp();
      Share.shareXFiles([XFile(qrFile.path)], text: "นี่คือ QR Code ของคุณ");
    } catch (e) {
      print("❌ แชร์ไม่สำเร็จ: $e");
    }
  }

  // **💾 2. บันทึก QR Code ลงเครื่อง**
  /*
  Future<void> _saveQRCode() async {
    try {
      File qrFile = await _captureAndSaveTemp();
      final result = await ImageGallerySaver.saveFile(qrFile.path);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ บันทึก QR Code สำเร็จ!")),
        );
      }
    } catch (e) {
      print("❌ บันทึก QR Code ไม่สำเร็จ: $e");
    }
  }*/

  // **☁️ 3. อัปโหลด QR Code ไป Supabase Storage**
  Future<void> _uploadToSupabase() async {
    try {
      File qrFile = await _captureAndSaveTemp();
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        print("❌ ไม่มีผู้ใช้ที่เข้าสู่ระบบ");
        return;
      }

      print("✅ auth_uid ปัจจุบัน: ${user.id}"); // ตรวจสอบ auth_uid

      // ✅ สร้าง JSON `qrcode` ให้ถูกต้อง
      Map<String, dynamic> qrData = {
        'controller': widget.controller.text,
      };

      if (widget.initial == 'พร้อมเพย์') {
        qrData['paycontroller'] = widget.paycontroller.text;
      }

      final response = await supabase.from('Qrcode').insert({
        'name': widget.name.text,
        'type': widget.initial,
        'qrcode': qrData, // ✅ JSON ถูกต้อง
        'auth_uid': user.id, // ✅ auth_uid เป็น UUID
      });

      if (response.error == null) {
        print("✅ เพิ่มข้อมูลสำเร็จ");
      } else {
        print("❌ เพิ่มข้อมูลไม่สำเร็จ: ${response.error.message}");
      }
    } catch (e) {
      print("❌ อัปโหลดไม่สำเร็จ: $e");
    }
  }

  // **📌 ฟังก์ชันจับภาพ QR Code และบันทึกเป็นไฟล์**
  Future<File> _captureAndSaveTemp() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qrcode.jpg');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      throw Exception("❌ ไม่สามารถจับภาพ QR Code ได้: $e");
    }
  }

  // **✅ ฟังก์ชันสร้าง QR Code สำหรับลิงค์หรือข้อความ**
  Widget _buildTextQR() {
    return QrImageView(
      data: widget.controller.text,
      size: 280,
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(100, 100),
      ),
    );
  }

  // **✅ ฟังก์ชันสร้าง QR Code สำหรับ PromptPay**
  Widget _buildPromptPayQR() {
    double? amount = double.tryParse(widget.paycontroller.text);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            height: 250,
            child: ThaiQRWidget(
              mobileOrId: widget.controller.text,
              amount: widget.paycontroller.text,
              showHeader: false,
            ),
          ),
          const SizedBox(height: 20),
          const Text("สแกนเพื่อจ่ายเงิน"),
        ],
      ),
    );
  }
}
