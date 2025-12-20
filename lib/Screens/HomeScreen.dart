import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'MainScaffold.dart';
import 'HomeBody.dart';
import 'ProfileScreenBody.dart';
import 'LogInScreen.dart';
import 'package:inventory_app/API/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userId = '';
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _newPassword = '';
  String _conPassword = '';
  String _role = '';
  String _profileImage = '';

  double totalSales = 0;
  double totalOutstanding = 0;
  double totalExpenses = 0;

  bool isHomeLoading = true;
  bool isProfileLoading = true;

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
    if (_selectedIndex == 0) {
      await _fetchDashboardData();
      await _fetchUsers();
    } else if (_selectedIndex == 2) {
      await _fetchProfile(_username);
    }
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    if (_username.isNotEmpty) {
      await _fetchProfile(_username);
    }
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
    setState(() => isProfileLoading = true);
    try {
      final data = await ApiService.getProfile(username);
      if (data['success'] == true) {
        setState(() {
          _userId = data['Id'] ?? '';
          _firstName = data['First_Name'] ?? '';
          _lastName = data['Last_Name'] ?? '';
          _username = data['Username'] ?? '';
          _role = data['Status'] ?? '';
          _profileImage = data['Img'] ?? '';
        });
      } else {
        _showSessionErrorDialog();
      }
    } catch (e) {
      print("Error fetching profile: $e");
      _showSessionErrorDialog();
    } finally {
      setState(() => isProfileLoading = false);
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() => isHomeLoading = true);
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
    } finally {
      setState(() => isHomeLoading = false);
    }
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

    // Fetch data when tab is tapped
    if (index == 0) {
      _fetchDashboardData();
      _fetchUsers();
    } else if (index == 2 && _username.isNotEmpty) {
      _fetchProfile(_username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bodyScreens = [
      isHomeLoading
          ? Center(
        child: SizedBox(
          height: 80,
          width: 80,
          child: LoadingIndicator(
            indicatorType: Indicator.ballClipRotateMultiple,
            colors: [Color(0xFFbe3235)],
          ),
        ),
      )
          : HomeBody(
        firstName: _firstName,
        lastName: _lastName,
        isLoading: false,
        totalSales: totalSales,
        totalExpenses: totalExpenses,
        totalOutstanding: totalOutstanding,
        topCustomers: topCustomers,
        allUsers: allUsers,
        onRefresh: _handleRefresh,
      ),
      Center(child: Text("FAB Action Screen")), // index 1
      isProfileLoading
          ? Center(
        child: SizedBox(
          height: 80,
          width: 80,
          child: LoadingIndicator(
            indicatorType: Indicator.ballClipRotateMultiple,
            colors: [Color(0xFFbe3235)],
          ),
        ),
      )
          : ProfileScreenBody(
        userId: _userId,
        firstName: _firstName,
        lastName: _lastName,
        username: _username,
        newPassword: _newPassword,
        conPassword: _conPassword,
        role: _role,
        profileImage: _profileImage,
        isLoading: false,
        onRefresh: _handleRefresh,
      ),
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
