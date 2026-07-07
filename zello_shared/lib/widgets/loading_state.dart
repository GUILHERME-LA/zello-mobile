import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

class LoadingState extends StatelessWidget {
  final int cardCount;
  final int linesPerCard;

  const LoadingState({super.key, this.cardCount = 4, this.linesPerCard = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: cardCount,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: i < cardCount - 1 ? 12 : 0),
        child: SkeletonCard(lines: linesPerCard),
      ),
    );
  }
}
