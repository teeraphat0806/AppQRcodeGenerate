import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../component/sidebar_menu.dart';
import 'qrdetailscreen.dart';

final supabase = Supabase.instance.client;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> qrCodes = [];
  List<Map<String, dynamic>> favqrCodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (supabase.auth.currentSession == null) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
    loadQrCode();
    loadFavQrCode();
  }

  /// ✅ โหลดข้อมูลที่ Favourite เท่ากับ true
  Future<void> loadFavQrCode() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final fav_response = await supabase
          .from('Qrcode')
          .select()
          .eq('Favourite', true)
          .eq('auth_uid', user.id)
          .order('created_at', ascending: false);

      print("📌 ข้อมูล Favourite ที่ดึงมา: $fav_response");

      if (mounted) {
        setState(() {
          favqrCodes = List<Map<String, dynamic>>.from(fav_response);
        });
      }
    } catch (e) {
      print("❌ โหลดข้อมูล Favourite ผิดพลาด: $e");
    }
  }

  /// ✅ โหลด QR Code ทั้งหมด
  Future<void> loadQrCode() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('Qrcode')
          .select()
          .eq('auth_uid', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          qrCodes = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ โหลดข้อมูล QR Code ผิดพลาด: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// ✅ ฟังก์ชันลบ QR Code
  Future<void> deleteItem(int id) async {
    await supabase.from('Qrcode').delete().eq('id', id);
    loadQrCode();
    loadFavQrCode();
  }

  /// ✅ ฟังก์ชันกดหัวใจ
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await supabase.from('Qrcode').update({'Favourite': !isFavorite}).eq('id', id);
    loadQrCode();
    loadFavQrCode();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: SidebarMenu(
        menuItems: [
          MenuItem(
            icon: Icons.home,
            text: 'หน้าหลัก',
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          MenuItem(
            icon: Icons.qr_code,
            text: 'MakeQR',
            onTap: () => Navigator.pushReplacementNamed(context, '/createqr'),
          ),
        ],
        onLogout: () async {
          await supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: user == null
          ? const Center(child: Text('❌ No user logged in'))
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView( // ✅ เปลี่ยนจาก `Column` เป็น `ListView`
                    children: [
                      // ✅ Header ของ Favourite QR Codes
                      Text(
                        "❤️ Favourite QR Codes",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      favqrCodes.isEmpty
                          ? const Center(child: Text("ไม่มี Favourite"))
                          : ListView.builder(
                              shrinkWrap: true, // ✅ ป้องกัน Overflow
                              physics: NeverScrollableScrollPhysics(), // ✅ ป้องกันการ Scroll ซ้อน
                              itemCount: favqrCodes.length,
                              itemBuilder: (context, index) {
                                final qr = favqrCodes[index];
                                return buildQrItem(qr);
                              },
                            ),
                      const Divider(), // ✅ เส้นแบ่งระหว่าง Favorite กับ All QR

                      // ✅ Header ของ All QR Codes
                      Text(
                        "📂 All QR Codes",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      qrCodes.isEmpty
                          ? const Center(child: Text("ไม่มี QR Code"))
                          : ListView.builder(
                              shrinkWrap: true, // ✅ ป้องกัน Overflow
                              physics: NeverScrollableScrollPhysics(), // ✅ ป้องกันการ Scroll ซ้อน
                              itemCount: qrCodes.length,
                              itemBuilder: (context, index) {
                                final qr = qrCodes[index];
                                return buildQrItem(qr);
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  /// ✅ ฟังก์ชันแสดงรายการ QR Code
  Widget buildQrItem(Map<String, dynamic> qr) {
    return ListTile(
      title: Text(qr['name'] ?? "ไม่มีชื่อ"),
      subtitle: Text("ประเภท: ${qr['type']}"),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRDetailScreen(qrData: qr),
          ),
        );
        if (result == true) {
          loadQrCode();
          loadFavQrCode();
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              qr['Favourite'] == true ? Icons.favorite : Icons.favorite_border,
              color: qr['Favourite'] == true ? Colors.red : Colors.grey,
            ),
            onPressed: () => toggleFavorite(qr['id'], qr['Favourite'] ?? false),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: () => deleteItem(qr['id']),
          ),
        ],
      ),
    );
  }
}
