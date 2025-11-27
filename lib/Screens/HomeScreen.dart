import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:inventory_app/API/api_service.dart';
import 'MainScaffold.dart';
import 'HomeBody.dart';
import 'ProfileScreenBody.dart';
import 'LogInScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _role = '';
  String _profileImage = '';

  double totalSales = 0;
  double totalOutstanding = 0;
  double totalExpenses = 0;

  bool isLoading = true;

  int _selectedIndex = 0;

  List<dynamic> topCustomers = [];
  List<dynamic> allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadSession();
    _fetchDashboardData();
    _fetchUsers();
  }

  Future<void> _handleRefresh() async {
    await _fetchDashboardData();
    await _fetchProfile(_username);
    await _fetchUsers();
    setState(() {});
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    if (_username.isNotEmpty) {
      await _fetchProfile(_username);
    }
    setState(() {});
  }

  void _showSessionErrorDialog() {
    PanaraInfoDialog.show(
      context,
      title: "Session Expired",
      message: "Network issue or invalid session. Please login again.",
      buttonText: "OK",
      onTapDismiss: () {
        Navigator.pop(context);
        _logout();
      },
      panaraDialogType: PanaraDialogType.custom,
      color: Color(0xFFbe3235),
      barrierDismissible: false,
    );
  }

  void _showLogoutDialog() {
    PanaraConfirmDialog.show(
      context,
      title: "Logout",
      message: "Are you sure you want to logout?",
      confirmButtonText: "Yes",
      cancelButtonText: "No",
      onTapConfirm: () {
        Navigator.pop(context);
        _logout();
      },
      onTapCancel: () => Navigator.pop(context),
      panaraDialogType: PanaraDialogType.custom,
      color: Color(0xFFbe3235),
      barrierDismissible: false,
    );
  }

  Future<void> _fetchProfile(String username) async {
    try {
      final data = await ApiService.getProfile(username);
      if (data['success'] == true) {
        setState(() {
          _firstName = data['First_Name'] ?? '';
          _lastName = data['Last_Name'] ?? '';
          _role = data['Status'] ?? '';
          _profileImage = data['Img'] ?? '';
        });
      } else {
        _showSessionErrorDialog();
      }
    } catch (e) {
      print("Error fetching profile: $e");
      _showSessionErrorDialog();
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getDashboardSuperAdminData();
      if (data["success"] == "true") {
        final dashboard = data["pageData"];
        totalSales = double.tryParse(dashboard?["Total_Sales"]?.toString() ?? "0") ?? 0;
        totalOutstanding = double.tryParse(dashboard?["Total_Outstanding"]?.toString() ?? "0") ?? 0;
        totalExpenses = double.tryParse(dashboard?["Total_Expenses"]?.toString() ?? "0") ?? 0;

        if (data["topCustomers"] != null && data["topCustomers"] is List) {
          topCustomers = data["topCustomers"];
        }
      }
    } catch (e) {
      print("Dashboard Load Error: $e");
      _showSessionErrorDialog();
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await ApiService.getAllUsers();
      setState(() {
        allUsers = users;
      });
    } catch (e) {
      print("User Load Error: $e");
      _showSessionErrorDialog();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LogScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Screens list for IndexedStack
    final List<Widget> bodyScreens = [
      HomeBody(
        firstName: _firstName,
        lastName: _lastName,
        isLoading: isLoading,
        totalSales: totalSales,
        totalExpenses: totalExpenses,
        totalOutstanding: totalOutstanding,
        topCustomers: topCustomers,
        allUsers: allUsers,
        onRefresh: _handleRefresh,
      ),
      Center(child: Text("FAB Action Screen")), // index 1
      ProfileScreenBody(
        firstName: _firstName,
        lastName: _lastName,
        username: _username,
        role: _role,
        profileImage: _profileImage,
        isLoading: isLoading,
        onRefresh: _handleRefresh,
      ), // index 2
    ];

    return MainScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      onFabTapped: () => _onItemTapped(1),
      onLogoutTap: _showLogoutDialog,
      body: IndexedStack(
        index: _selectedIndex,
        children: bodyScreens,
      ),
    );
  }
}
