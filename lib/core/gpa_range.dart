import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GpaInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final InputDecoration? decoration;

  GpaInputField({
    Key? key,
    this.controller,
    this.labelText = 'أدخل رقم من 0.0 إلى 4.0',
    this.decoration,
  }) : super(key: key);

  @override
  _GpaInputFieldState createState() => _GpaInputFieldState();
}

class _GpaInputFieldState extends State<GpaInputField> {
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
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: widget.decoration ??
          InputDecoration(
            labelText: widget.labelText,
            border: OutlineInputBorder(),
          ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        GpaRangeFormatter(),
      ],
    );
  }
}

class GpaRangeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final double? number = double.tryParse(newValue.text);
    if (number == null || number < 0.0 || number > 4.0) {
      return oldValue;
    }

    final regex = RegExp(r'^\d{0,1}(\.\d{0,2})?$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    return newValue;
  }
}
