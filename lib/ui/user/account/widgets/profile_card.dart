import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_assist/data/models/user_model.dart';

class ProfileCard extends StatefulWidget {
  final UserModel user;
  final Function(File file)? onAvatarPicked;

  const ProfileCard({
    super.key,
    required this.user,
    this.onAvatarPicked,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final ImagePicker _picker = ImagePicker();
  File? _avatarFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    setState(() {
      _avatarFile = file;
    });

    // 👉 Gửi file lên Screen cha
    widget.onAvatarPicked?.call(file);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color.fromRGBO(25, 37, 59, 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 255, 255, 0.6),
            offset: Offset(2, 6),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          /// ===== AVATAR =====
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4B4CED),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (widget.user.avatarUrl != null
                          ? NetworkImage(widget.user.avatarUrl!)
                          : const AssetImage(
                        'assets/images/illustrations/avatarDefault.png',
                      )) as ImageProvider,
                    ),
                  ),
                ),

                /// ICON CHECK / STATUS
                Positioned(
                  bottom: -2,
                  right: 0,
                  child: Icon(
                    Icons.check_circle,
                    color: widget.user.email == null
                        ? Colors.grey
                        : Colors.green,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          /// ===== INFO =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 27,
                  ),
                ),
                Text(
                  widget.user.phone,
                  style: const TextStyle(
                    color: Color.fromRGBO(111, 127, 161, 1),
                    fontSize: 17,
                  ),
                ),
                Text(
                  widget.user.email ?? 'Thêm Email',
                  style: TextStyle(
                    color: widget.user.email == null
                        ? Colors.redAccent
                        : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
