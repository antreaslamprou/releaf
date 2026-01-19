import 'package:flutter/material.dart';

class ColorPickerGrid extends StatelessWidget {
  ColorPickerGrid({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final List<Color> colors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.yellow,
  ];

  final Color selectedColor;
  final Function(Color) onColorSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: colors.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colors.length,
        crossAxisSpacing: 15,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final color = colors[index];
        bool isSelected = color == selectedColor;
        return Container(
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(width: 3, color: Colors.black)
                    : null,
              ),
              child: GestureDetector(onTap: () => onColorSelected(color)),
            ),
          ),
        );
      },
    );
  }
}
