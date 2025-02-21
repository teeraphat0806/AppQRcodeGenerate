import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {

  final List<MenuItem> menuItems;
  final VoidCallback onLogout;

  const SidebarMenu({
    Key? key,

    required this.menuItems,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [SizedBox(height: 40,),
          ...menuItems.map((item) => _buildDrawerItem(context, item)).toList(),
          Divider(),
          _buildDrawerItem(
            context,
            MenuItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }

 

  Widget _buildDrawerItem(BuildContext context, MenuItem item) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.blue),
      title: Text(item.text, style: TextStyle(fontSize: 16)),
      onTap: item.onTap,
    );
  }
}

class MenuItem {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.text, required this.onTap});
}
/*
drawer: userInfo.when(
        loading: () => SidebarMenu(
          accountName: "Loading...",
          accountEmail: "Loading...",
          menuItems: [],
          onLogout: () async {
            await supabase.auth.signOut();
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        error: (err, _) => SidebarMenu(
          accountName: "Error",
          accountEmail: "Error",
          menuItems: [],
          onLogout: () async {
            await supabase.auth.signOut();
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        data: (user) => SidebarMenu(
          accountName: user['name']!,
          accountEmail: user['email']!,
          menuItems: [
            MenuItem(
              icon: Icons.home,
              text: 'Home',
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            MenuItem(
              icon: Icons.shopping_cart,
              text: 'Cart',
              onTap: () => Navigator.pushReplacementNamed(context, '/createqr'),
            ),
            
          ],
          onLogout: () async {
            await supabase.auth.signOut();
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),

*/