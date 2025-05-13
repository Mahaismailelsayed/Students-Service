import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final InputDecoration? decoration;

  NumberInputField({
    Key? key,
    this.controller,
    this.labelText = 'أدخل رقم من 1 إلى 4',
    this.decoration,
  }) : super(key: key);

  @override
  _NumberInputFieldState createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: widget.decoration ?? InputDecoration(
        labelText: widget.labelText,
        border: OutlineInputBorder(),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumberRangeFormatter(),
      ],
    );
  }
}

class NumberRangeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? number = int.tryParse(newValue.text);
    if (number == null || number < 1 || number > 4) {
      return oldValue;
    }

    return newValue;
  }
}