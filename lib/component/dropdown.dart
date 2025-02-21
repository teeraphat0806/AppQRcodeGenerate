import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  final List<String> items;
  final String initial;
  final Function(String) onChanged;

  const Dropdown({
    super.key,
    required this.items,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      isExpanded: true,
      items: widget.items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            dropdownValue = newValue;
          });
          widget.onChanged(newValue);
        }
      },
    );
  }
}
