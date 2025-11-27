import 'package:flutter/material.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int)? onItemTapped;
  final Function()? onFabTapped;
  final Function()? onLogoutTap;

  const MainScaffold({
    required this.body,
    required this.selectedIndex,
    this.onItemTapped,
    this.onFabTapped,
    this.onLogoutTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/logo.png', height: 80),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: onLogoutTap,
          )
        ],
      ),

      // BODY
      body: body,

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // HOME
              InkWell(
                onTap: () => onItemTapped?.call(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, color: selectedIndex == 0 ? Color(0xFFbe3235) : Colors.grey),
                    Text("Home", style: TextStyle(fontSize: 11, color: selectedIndex == 0 ? Color(0xFFbe3235) : Colors.grey)),
                  ],
                ),
              ),

              SizedBox(width: 40),

              // PROFILE
              InkWell(
                onTap: () => onItemTapped?.call(2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: selectedIndex == 2 ? Color(0xFFbe3235) : Colors.grey),
                    Text("Profile", style: TextStyle(fontSize: 11, color: selectedIndex == 2 ? Color(0xFFbe3235) : Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: onFabTapped,
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Color(0xFFbe3235),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Center(
            child: SizedBox(
              height: 25,
              width: 25,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(4, (index) => Container(color: Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
