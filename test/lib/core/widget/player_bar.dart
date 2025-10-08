import 'package:flutter/material.dart';

class PlayerBar extends StatelessWidget {
  final String title;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  const PlayerBar({
    super.key,
    required this.title,
    required this.onPlay,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          IconButton(onPressed: onPlay, icon: const Icon(Icons.play_arrow)),
          IconButton(onPressed: onPause, icon: const Icon(Icons.pause)),
        ],
      ),
    );
  }
}
