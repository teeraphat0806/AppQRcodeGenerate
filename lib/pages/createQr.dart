import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrcodegenerator/component/dropdown.dart';
import '../component/dropdown.dart';
import '../component/qrcode.dart';
import 'package:thaiqr/thaiqr.dart';

class CreateQr extends StatefulWidget {
  const CreateQr({super.key});

  @override
  State<CreateQr> createState() => _CreateQrState();
}

class _CreateQrState extends State<CreateQr> {
  String initial = 'ลิงค์ หรือ คำ';
  TextEditingController controller = TextEditingController();
  TextEditingController paycontroller = TextEditingController();
  TextEditingController name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "QR Code Generator",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // ไอคอนย้อนกลับ
          onPressed: () {
            Navigator.pushNamed(context, '/home'); // ✅ กลับไปหน้าก่อนหน้า
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Enter QRcode Name'),
            ),
            Dropdown(
              items: ['ลิงค์ หรือ คำ', 'พร้อมเพย์'],
              initial: initial,
              onChanged: (String newValue) {
                setState(() {
                  initial = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            if (initial == 'ลิงค์ หรือ คำ')
              LinkQr(controller: controller)
            else
              Promptpay(controller: controller, paycontroller: paycontroller),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { 
                if (name.text.trim().isNotEmpty) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QRImage(
                              initial, controller, paycontroller, name)));
                }
              },
              child: const Text('Generate QR Code'),
            )
          ],
        ),
      ),
    );
  }
}

class LinkQr extends StatefulWidget {
  final TextEditingController controller;
  const LinkQr({super.key, required this.controller});

  @override
  State<LinkQr> createState() => _CreateLinkQr();
}

class _CreateLinkQr extends State<LinkQr> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: 'Enter your URL | Text'),
    );
  }
}

class Promptpay extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController paycontroller;
  const Promptpay(
      {super.key, required this.controller, required this.paycontroller});

  @override
  State<Promptpay> createState() => _CreatePromptpay();
}

class _CreatePromptpay extends State<Promptpay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.number, // รับเฉพาะตัวเลข
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Account number'),
        ),
        SizedBox(
          height: 20,
        ),
        TextField(
          controller: widget.paycontroller,
          keyboardType: TextInputType.number, // รับเฉพาะตัวเลข
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Amount'),
        )
      ],
    );
  }
}
