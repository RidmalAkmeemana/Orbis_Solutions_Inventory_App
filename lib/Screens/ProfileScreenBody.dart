import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ProfileScreenBody extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String role;
  final String profileImage;
  final bool isLoading;
  final Future<void> Function()? onRefresh;

  const ProfileScreenBody({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.role,
    required this.profileImage,
    this.isLoading = false,
    this.onRefresh,
    Key? key,
  }) : super(key: key);

  Widget _buildProfileField(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildProfileBody() {
    final fullName = '$firstName $lastName';
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
              profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
              child: profileImage.isEmpty
                  ? Icon(Icons.person, size: 45, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(height: 15),
          Text(fullName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(role,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFbe3235),
                fontWeight: FontWeight.w500,
              )),
          SizedBox(height: 30),
          _buildProfileField("Username", username),
          _buildProfileField("User Role", role),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: 80,
          width: 80,
          child: LoadingIndicator(
            indicatorType: Indicator.ballClipRotateMultiple,
            colors: [Color(0xFFbe3235)],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      color: Color(0xFFbe3235),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: _buildProfileBody(),
      ),
    );
  }
}
