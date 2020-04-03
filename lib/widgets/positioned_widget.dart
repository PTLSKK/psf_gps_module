import 'package:flutter/material.dart';

class PositionedWidget extends StatelessWidget {
  PositionedWidget(
      {this.isHide,
      this.appState,
      this.top,
      this.hintText,
      this.icon,
      this.onSubmitFunction,
      this.onTapFunction});

  final bool isHide;
  final TextEditingController appState;
  final double top;
  final String hintText;
  final Icon icon;
  final Function onSubmitFunction;
  final Function onTapFunction;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: 15.0,
      left: 15.0,
      child: AnimatedOpacity(
        opacity: isHide ? 0 : 1,
        duration: Duration(milliseconds: 300),
        child: Visibility(
          visible: isHide ? false : true,
          child: Container(
            height: 50.0,
            width: 10.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.white,
            ),
            child: TextField(
              cursorColor: Colors.black,
              controller: appState,
              style: TextStyle(color: Colors.black),
              onSubmitted: (value) {
                onSubmitFunction(value);
              },
              onTap: onTapFunction,
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 20, top: 5),
                  width: 10,
                  height: 10,
                  child: icon,
                ),
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
