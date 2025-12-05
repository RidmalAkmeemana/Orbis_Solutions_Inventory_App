// ProfileScreenBody.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:inventory_app/API/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LogInScreen.dart';

class ProfileScreenBody extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String role;
  final String profileImage;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onChangePhoto;
  final bool isImageUploading;

  // Callbacks for Account Settings
  final VoidCallback? onUpdateAccount;
  final VoidCallback? onResetPassword;
  final VoidCallback? onLogout;

  const ProfileScreenBody({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.role,
    required this.profileImage,
    this.isLoading = false,
    this.onRefresh,
    this.onChangePhoto,
    this.isImageUploading = false,
    this.onUpdateAccount,
    this.onResetPassword,
    this.onLogout,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreenBody> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  // wrapper to access widget.username easily
  String get _username => widget.username;

  // ------------------- pick & upload -------------------
  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 75);
      if (picked == null) return;

      setState(() => _uploading = true);

      // call ApiService.uploadProfileImage which returns Map<String,dynamic>
      final result = await ApiService.uploadProfileImage(
        username: _username,
        imageFile: File(picked.path),
      );

      // Expect result['success'] == true (string "true" or bool true)
      final successFlag = result['success'];
      final bool success = (successFlag == true) || (successFlag == 'true');

      if (success) {
        // show success and on OK: close dialog AND refresh profile
        PanaraInfoDialog.show(
          context,
          title: "Success",
          message: "Profile image uploaded successfully.",
          buttonText: "OK",
          panaraDialogType: PanaraDialogType.custom,
          color: Color(0xFFbe3235),
          onTapDismiss: () async {
            Navigator.pop(context); // Close popup first

            // Now refresh profile UI
            if (widget.onRefresh != null) {
              await widget.onRefresh!.call();
            }
          },
        );
      } else {
        // show failure (server may include message)
        final message = result['message']?.toString() ?? 'Upload failed';
        PanaraInfoDialog.show(
          context,
          title: "Upload Failed",
          message: message,
          buttonText: "OK",
          onTapDismiss: () => Navigator.pop(context),
          panaraDialogType: PanaraDialogType.custom,
          color: Color(0xFFbe3235),
        );
      }
    } catch (e) {
      print("Image upload error: $e");
      PanaraInfoDialog.show(
        context,
        title: "Error",
        message: "An error occurred while uploading the image.",
        buttonText: "OK",
        onTapDismiss: () => Navigator.pop(context),
        panaraDialogType: PanaraDialogType.custom,
        color: Color(0xFFbe3235),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // Show dialog, call local pick/upload functions
  void _showImageOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Update Profile Image",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo, color: Color(0xFFbe3235)),
              title: Text("Select From Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFFbe3235)),
              title: Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Color(0xFFbe3235)),
              title: Text("Cancel"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // LogOut Function

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to LogInScreen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LogScreen()),
          (route) => false,
    );
  }
  // Show Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    PanaraConfirmDialog.show(
      context,
      title: "Logout",
      message: "Are you sure you want to logout?",
      confirmButtonText: "Yes",
      cancelButtonText: "No",
      onTapConfirm: () {
        Navigator.pop(context); // Close the dialog
        _logout(context);       // Perform logout
      },
      onTapCancel: () => Navigator.pop(context),
      panaraDialogType: PanaraDialogType.custom,
      color: Color(0xFFbe3235),
      barrierDismissible: false,
    );
  }

  Widget _buildProfileField() {
    return Container(margin: EdgeInsets.symmetric(vertical: 8), padding: EdgeInsets.all(12));
  }

  Widget _buildProfileBody(BuildContext context) {
    final fullName = '${widget.firstName} ${widget.lastName}';

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                widget.profileImage.isNotEmpty ? NetworkImage(widget.profileImage) : null,
                child: widget.profileImage.isEmpty
                    ? Icon(Icons.person, size: 45, color: Colors.white)
                    : null,
              ),

              // image uploading overlay
              if (_uploading || widget.isImageUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballClipRotateMultiple,
                          colors: [Color(0xFFbe3235)],
                        ),
                      ),
                    ),
                  ),
                ),

              // Edit Icon
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // call external onChangePhoto if provided (keeps backward compat)
                    if (widget.onChangePhoto != null) {
                      // If external handler exists, call it - but still open options here too
                      widget.onChangePhoto!.call();
                    } else {
                      _showImageOptions(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFFbe3235),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 15),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(fullName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          Text(widget.role,
              style: TextStyle(fontSize: 16, color: Color(0xFFbe3235), fontWeight: FontWeight.w500)),
          _buildProfileField(),

          // UPDATE PROFILE CARD
          Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: ListTile(
              leading: Icon(Icons.settings, color: Color(0xFFbe3235), size: 24),
              title: Text("Update Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              onTap: widget.onUpdateAccount,
            ),
          ),

          // RESET PASSWORD CARD
          Container(
            margin: EdgeInsets.only(bottom: 25),
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: ListTile(
              leading: Icon(Icons.lock, color: Color(0xFFbe3235), size: 24),
              title: Text("Reset Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              onTap: widget.onResetPassword,
            ),
          ),

          SizedBox(height: 15),

          // LOGOUT BUTTON
          Center(
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFFbe3235)),
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          height: 80,
          width: 80,
          child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple, colors: [Color(0xFFbe3235)]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      color: Color(0xFFbe3235),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 200),
          child: _buildProfileBody(context),
        ),
      ),
    );
  }
}
