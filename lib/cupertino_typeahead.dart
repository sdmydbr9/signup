import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoTypeAhead<T> extends StatefulWidget {
  final TextEditingController controller;
  final Future<List<T>> Function(String) suggestionsCallback;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T) onSuggestionSelected;

  const CupertinoTypeAhead({
    required this.controller,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
  });

  @override
  _CupertinoTypeAheadState<T> createState() => _CupertinoTypeAheadState<T>();
}

class _CupertinoTypeAheadState<T> extends State<CupertinoTypeAhead<T>> {
  List<T> _suggestions = [];
  bool _isFetchingSuggestions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CupertinoFormRow(
          child: CupertinoTextField(
            controller: widget.controller,
            placeholder: 'Type to search',
            onChanged: _onChanged,
            clearButtonMode: OverlayVisibilityMode.editing,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: CupertinoColors.white,
              border: Border.all(color: CupertinoColors.lightBackgroundGray),
            ),
          ),
        ),
        if (_isFetchingSuggestions)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoActivityIndicator(),
          ),
        if (!_isFetchingSuggestions && _suggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: CupertinoColors.white.withOpacity(0.7),
            ),
            child: CupertinoScrollbar(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      widget.onSuggestionSelected(_suggestions[index]);
                      setState(() {
                        _suggestions.clear();
                      });
                    },
                    child: ListTile(
                      title: widget.itemBuilder(context, _suggestions[index]),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: CupertinoColors.lightBackgroundGray,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onChanged(String value) async {
    setState(() {
      _isFetchingSuggestions = true;
      _suggestions.clear();
    });

    try {
      if (value.isNotEmpty && _hasAlphabetCharacters(value)) {
        List<T> suggestions = await widget.suggestionsCallback(value);
        setState(() {
          _suggestions = suggestions;
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    } finally {
      setState(() {
        _isFetchingSuggestions = false;
      });
    }
  }

  bool _hasAlphabetCharacters(String text) {
    return RegExp(r'[a-zA-Z]').hasMatch(text);
  }
}
