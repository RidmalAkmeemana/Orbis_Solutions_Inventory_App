import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //static const String _baseUrl = 'https://uat.orbislk.com';
  static const String _baseUrl = 'https://uat.orbislk.com/Orbis_Solutions_Inventory_System/API/MobileApp';
  static const String _loginEndpoint = '$_baseUrl/getAdminLogin.php';
  static const String _profileEndpoint = '$_baseUrl/getProfileDetails.php';
  static const String _dashboardEndpoint = '$_baseUrl/getDashboardSuperAdminData.php';
  static const String _userEndpoint = '$_baseUrl/getAllUserData.php';

  /// Calls login endpoint. Returns decoded JSON map on success.
  /// Throws an Exception for network errors.
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse(_loginEndpoint);

    // Use application/x-www-form-urlencoded by default (works with most PHP endpoints)
    final response = await http.post(uri, body: {
      'username': username,
      'password': password,
    }, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Network error: ${response.statusCode}');
    }

    // Some servers return JSON with content-type text/html; still decode
    final Map<String, dynamic> jsonBody = json.decode(response.body);
    return jsonBody;
  }

  static Future<Map<String, dynamic>> getProfile(String username) async {
    final uri = Uri.parse("$_profileEndpoint?username=$username");

    final response = await http.get(uri);

    //print("Profile API Response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load profile. Status: ${response.statusCode}");
    }

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getDashboardSuperAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("username") ?? "";

    final uri = Uri.parse("$_dashboardEndpoint?username=$username");
    final response = await http.get(uri);

    //print("Dashboard API Response: ${response.body}"); // <--- ADD THIS

    if (response.statusCode != 200) {
      throw Exception("Failed to load dashboard data");
    }

    return json.decode(response.body);
  }

  //(Get All User List)
  static Future<List<dynamic>> getAllUsers() async {
    final uri = Uri.parse("$_userEndpoint");
    final response = await http.get(uri);

    // print("Users API Response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load user list. Status: ${response.statusCode}");
    }

    // The API returns JSON array (list), so decode to List
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList;
  }

}
