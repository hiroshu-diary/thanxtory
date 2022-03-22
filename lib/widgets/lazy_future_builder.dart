import 'package:flutter/material.dart';

class LazyFutureBuilder extends StatefulWidget {
  final Future Function() futureBuilder;
  final Widget Function(
    BuildContext context,
    Future Function() futureBuilder,
    bool isFutureBuilding,
  ) builder;

  const LazyFutureBuilder({
    Key? key,
    required this.futureBuilder,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LazyFutureBuilder> {
  var _isFutureBuilding = false;

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      () async {
        if (_isFutureBuilding) {
          return;
        }
        setState(() {
          _isFutureBuilding = true;
        });
        try {
          await widget.futureBuilder();
        } finally {
          setState(() {
            _isFutureBuilding = false;
          });
        }
      },
      _isFutureBuilding,
    );
  }
}
