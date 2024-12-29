import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../utils/constant.dart';

// Height of your Container
// const double appBarHeight = 80.0;

class MyAppBarEmpty extends StatefulWidget {
  final ScrollController controller;
  final double appBarHeight;
  final double runAfter;
  const MyAppBarEmpty(
      {Key? key,
      required this.controller,
      this.appBarHeight = 80.0,
      this.runAfter = 56.0})
      : super(
          key: key,
        );

  @override
  State<MyAppBarEmpty> createState() => _MyAppBarEmptyState();
}

class _MyAppBarEmptyState extends State<MyAppBarEmpty> {
  // You don't need to change any of these variables
  var _fromTop;
  var _allowReverse = true, _allowForward = true;
  var _prevOffset = 0.0;
  var _prevForwardOffset;
  var _prevReverseOffset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
    _fromTop = -widget.appBarHeight;
    _prevForwardOffset = -widget.appBarHeight;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // entire logic is inside this listener for ListView
  void _listener() async {
    double offset = widget.controller.offset;
    var direction = widget.controller.position.userScrollDirection;
    var max = 0.0;
    if (direction == ScrollDirection.reverse && offset > widget.runAfter) {
      _allowForward = true;
      if (_allowReverse) {
        _allowReverse = false;
        _prevOffset = offset;
        _prevReverseOffset = _fromTop;
      }
      var difference = offset - _prevOffset;

      if (_fromTop < max) {
        max = _fromTop;
        _fromTop = _prevReverseOffset + difference;
      }

      if (_fromTop > 0) {
        _fromTop = 0.0;
      }
    } else if (direction == ScrollDirection.forward &&
        offset < widget.appBarHeight * 2) {
      _allowReverse = true;
      max = -100.0;
      if (_allowForward) {
        _allowForward = false;
        _prevOffset = offset;
        _prevForwardOffset = _fromTop;
      }
      var difference = offset - _prevOffset;
      _fromTop = _prevForwardOffset + difference;
      if (_fromTop < -widget.appBarHeight) _fromTop = -widget.appBarHeight;
    }

    setState(
        () {}); // for simplicity I'm calling setState here, you can put bool values to only call setState when there is a genuine change in _fromTop
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // top: _fromTop,
      top: 0,
      left: 0,
      right: 0,
      child: MyAppBarEmptyWidget(
        fromTop: _fromTop,
        appBarHeight: widget.appBarHeight,
      ),
    );
  }
}

class MyAppBarEmptyWidget extends StatelessWidget {
  final double fromTop;
  final double appBarHeight;
  const MyAppBarEmptyWidget(
      {Key? key, required this.fromTop, required this.appBarHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1 - (-fromTop / appBarHeight),
      child: Container(
        height: appBarHeight,
        decoration: BoxDecoration(
          color: kBackground,
          border: Border(
            bottom: BorderSide(color: kGray70, width: 0.3),
          ),
        ),
      ),
    );
  }
}
