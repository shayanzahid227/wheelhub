import 'package:flutter/material.dart';

class StickerPanel extends StatelessWidget {
  final Function(String)? onStickerSelected;

  const StickerPanel({super.key, this.onStickerSelected});

  @override
  Widget build(BuildContext context) {
    List<String> stickers = ["😂", "🥰", "🎉", "🍕", "🍫", "🙌", "🔥", "👍"];

    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stickers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (onStickerSelected != null) {
                onStickerSelected!(stickers[index]);
              }
            },
            child: Center(
              child: Text(
                stickers[index],
                style: const TextStyle(fontSize: 32),
              ),
            ),
          );
        },
      ),
    );
  }
}
