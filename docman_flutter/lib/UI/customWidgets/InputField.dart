import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:docman_flutter/supports/Constants.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final int maxlines;
  final bool enabled;
  final bool isPassword;
  final Function onChanged;
  final Function onSubmit;
  final Function onTap;
  final int maxLength;
  final TextAlign textAlign;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget suffixIcon;
  final String hint;
  final Color backgroundColor;


  const InputField({Key key, this.labelText, this.controller, this.onChanged, this.onSubmit, this.onTap, this.keyboardType, this.maxlines = 1, this.textAlign = TextAlign.left, this.maxLength, this.isPassword = false, this.enabled = true, this.suffixIcon, this.hint, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: TextField(
        enabled: enabled,
        maxLength: maxLength,
        obscureText: isPassword,
        textAlign: textAlign,
        maxLines: maxlines,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number ? <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        ] : null,
        onChanged: onChanged,
        onSubmitted: onSubmit,
        onTap: onTap,
        controller: controller,
        style: TextStyle(fontSize: 16.0),
        decoration: InputDecoration(
          hintText: hint,
          filled: backgroundColor == null ? false : true,
          fillColor: backgroundColor,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.grey,
          ),
          suffixIcon: suffixIcon,
        ),
        textAlignVertical: TextAlignVertical.center,

      ),
    );
  }


}