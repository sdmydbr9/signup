import 'package:flutter/cupertino.dart';

class CupertinoDropdown extends StatefulWidget {
  final TextEditingController controller;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final bool enabled;

  CupertinoDropdown({
    required this.controller,
    required this.items,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  _CupertinoDropdownState createState() => _CupertinoDropdownState();
}

class _CupertinoDropdownState extends State<CupertinoDropdown> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? _showPicker : null,
      child: AbsorbPointer(
        absorbing: true,
        child: CupertinoTextField(
          controller: widget.controller,
          placeholder: 'Select an option',
          enabled: widget.enabled,
          decoration: BoxDecoration(
            border: Border.all(
              color: CupertinoColors.inactiveGray,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  void _showPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.6,
          child: CupertinoActionSheet(
            actions: [
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                child: CupertinoScrollbar(
                  child: ListView(
                    children: widget.items.map((String value) {
                      return CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            widget.controller.text = value;
                            widget.onSelected(value);
                          });
                          Navigator.pop(context);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(value, textAlign: TextAlign.center),
                            ),
                            Container(
                              height: 0.25,
                              color: CupertinoColors.separator.withOpacity(0.2),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ),
        );
      },
    );
  }
}
