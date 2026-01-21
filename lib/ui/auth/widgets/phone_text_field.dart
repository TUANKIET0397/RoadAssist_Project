import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const PhoneTextField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF37B6E9);
    const hintColor = Colors.white;
    const inputColor = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 56.0,
      decoration: BoxDecoration(
        color: const Color(0xFF000718),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            hint,
            style: const TextStyle(
              color: hintColor,
              fontSize: 16.0,
            ),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '+84',
                  style: TextStyle(
                    color: borderColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  width: 95,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: inputColor,
                      fontSize: 16.0,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: ' 9xxxxxxxx',
                      hintStyle: TextStyle(
                        color: borderColor,
                        fontSize: 16.0,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
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
