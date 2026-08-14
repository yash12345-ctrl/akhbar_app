import 'package:flutter/material.dart';

class SearchNewsBox extends StatefulWidget {
  const SearchNewsBox({super.key});

  @override
  State<StatefulWidget> createState() => _SearchNewsBox();
}

class _SearchNewsBox extends State<SearchNewsBox> {

  @override
  build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 12,
          height: 1,
        ),
        decoration: InputDecoration(
          hintText: "Search news...",
          hintStyle: const TextStyle(
            color: Color(0xFF888888),
          ),
          fillColor: const Color(0xFFFFFFFF),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xFFE3DEDE),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xFF888888),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          // This is the old way to add border, but it doesn't work now. Use enabledBorder instead.
          // border: OutlineInputBorder(
          //   borderSide: const BorderSide(
          //     width: 1,
          //     color: Color(0xFFE3DEDE),
          //   ),
          //   borderRadius: BorderRadius.circular(8),
          // ),

          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}