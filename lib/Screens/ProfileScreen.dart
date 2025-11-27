import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import 'LogInScreen.dart';
import 'HomeScreen.dart';
import 'MainScaffold.dart';
import 'ProfileScreenBody.dart';
import 'package:inventory_app/API/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _firstName = '';
  String _lastName = '';
  String _userRole = '';
  String _profileImage = "";
  bool isLoading = true;

  int _selectedIndex = 2; // Highlight Profile

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _handleRefresh() async {
    await _fetchProfile(_userName);
    setState(() {});
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('username') ?? '';
    if (_userName.isNotEmpty) {
      await _fetchProfile(_userName);
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
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getProfile(username);
      if (data['success'] == true) {
        setState(() {
          _firstName = data['First_Name'] ?? '';
          _lastName = data['Last_Name'] ?? '';
          _userName = data['Username'] ?? '';
          _userRole = data['Status'] ?? '';
          _profileImage = data["Img"] ?? "";
        });
      } else {
        _showSessionErrorDialog();
      }
    } catch (e) {
      print("Error fetching profile: $e");
      _showSessionErrorDialog();
    }
    setState(() => isLoading = false);
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

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      onLogoutTap: _showLogoutDialog,
      onFabTapped: () => _onItemTapped(1),
      body: ProfileScreenBody(
        firstName: _firstName,
        lastName: _lastName,
        username: _userName,
        role: _userRole,
        profileImage: _profileImage,
        isLoading: isLoading,
        onRefresh: _handleRefresh,
      ),
    );
  }
}
