import 'package:customer/components/constants.dart';
import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget {
  const FormContainerWidget({
    super.key,
    this.controller,
    this.fieldKey,
    this.isPasswordField,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.inputType,
    this.icon,
    this.isDisabled,
  });
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?>? onFieldSubmitted;
  final TextInputType? inputType;
  final IconData? icon;
  final bool? isDisabled;
  @override
  State<FormContainerWidget> createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;
  bool _isDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Text(
      // widget.labelText?.trim().toString() ?? '',
      // style: TextStyle(color: kPrimaryColor),
      // ),
      // SizedBox(height: 4),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isDisabled == true
              ? Colors.black26
              : kPrimaryColor.withOpacity(.35),
          borderRadius: BorderRadius.circular(100),
        ),
        child: TextFormField(
          readOnly: widget.isDisabled == true ? true : false,
          style: TextStyle(
              color: kPrimaryColor,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500),
          cursorColor: kPrimaryColor,
          controller: widget.controller,
          // keyboardType: widget.inputType,
          key: widget.fieldKey,
          obscureText: widget.isPasswordField == true ? _obscureText : false,
          onSaved: widget.onSaved,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              hintText: widget.hintText,
              hintStyle:
                  const TextStyle(color: Color.fromARGB(115, 83, 73, 73)),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: widget.isPasswordField == true
                    ? Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: _obscureText == false
                            ? kPrimaryColor
                            : kPrimaryLightColor,
                      )
                    : const Text(""),
              )),
        ),
      ),
    ]);
  }
}
