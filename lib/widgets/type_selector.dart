import 'package:flutter/material.dart';

class TypeSelector extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const TypeSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<TypeSelector> createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => widget.onChanged(0),
            child: SizedBox(
              height: widget.selectedIndex == 0 ? 60 : 38,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  widget.selectedIndex == 0
                      ? 'assets/type/pebbo_home_popular_selete.webp'
                      : 'assets/type/pebbo_home_popular_nor.webp',
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          GestureDetector(
            onTap: () => widget.onChanged(1),
            child: SizedBox(
              height: widget.selectedIndex == 1 ? 60 : 38,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  widget.selectedIndex == 1
                      ? 'assets/type/pebbo_home_new_selete.webp'
                      : 'assets/type/pebbo_home_new_nor.webp',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

