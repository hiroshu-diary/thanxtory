import 'package:flutter/material.dart';

import '../../model/constant.dart';

Padding editForm(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
    child: TextFormField(
      controller: controller,
      cursorColor: C.accentColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: C.subColor),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: C.mainColor,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: C.subColor),
        ),
      ),
    ),
  );
}

Padding pWForm(TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
    child: TextFormField(
      controller: controller,
      cursorColor: C.accentColor,
      decoration: const InputDecoration(
        labelText: 'パスワード（8～20文字）',
        labelStyle: TextStyle(color: C.subColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: C.mainColor,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: C.subColor),
        ),
      ),
      obscureText: true,
      maxLength: 20,
    ),
  );
}
