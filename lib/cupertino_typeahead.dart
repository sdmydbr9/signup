import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoTypeAhead extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onSelected;
  final Duration debounceDuration;
  final bool enabled;

  CupertinoTypeAhead({
    required this.controller,
    required this.suggestions,
    required this.onSelected,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.enabled = true,
  });

  @override
  _CupertinoTypeAheadState createState() => _CupertinoTypeAheadState();
}

class _CupertinoTypeAheadState extends State<CupertinoTypeAhead> {
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  bool _isSuggestionsVisible = false;
  bool _shouldNotify = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_shouldNotify) return;

    if (widget.controller.text.isEmpty || !widget.enabled) {
      setState(() {
        _isSuggestionsVisible = false;
        _filteredSuggestions = [];
      });
      return;
    }

    setState(() {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) => suggestion
              .toLowerCase()
              .contains(widget.controller.text.toLowerCase()))
          .toList();
      _isSuggestionsVisible = _filteredSuggestions.isNotEmpty;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _isSuggestionsVisible = _focusNode.hasFocus &&
          _filteredSuggestions.isNotEmpty &&
          widget.enabled;
    });
  }

  void _onSuggestionSelected(String suggestion) {
    _shouldNotify = false;
    widget.controller.text = suggestion;
    widget.onSelected(suggestion);
    setState(() {
      _isSuggestionsVisible = false;
    });
    widget.controller.notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shouldNotify = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoTextField(
          controller: widget.controller,
          focusNode: _focusNode,
          placeholder: 'Type a name',
          enabled: widget.enabled,
          decoration: BoxDecoration(
            border: Border.all(
              color: CupertinoColors.inactiveGray,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          onTap: () {
            setState(() {
              _isSuggestionsVisible = _filteredSuggestions.isNotEmpty;
            });
          },
        ),
        if (_isSuggestionsVisible)
          Material(
            color: Colors.transparent,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    _onSuggestionSelected(suggestion);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
