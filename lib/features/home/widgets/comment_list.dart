import 'package:flutter/material.dart';
import '../models/comment_model.dart';

class CommentList extends StatelessWidget {
  final List<CommentModel> comments;
  final Function(int, String) onReaction;

  const CommentList({
    required this.comments,
    required this.onReaction,
  });

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      (comment.user.name.isNotEmpty == true)
                          ? comment.user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.user.name ?? 'مستخدم',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          _formatDate(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(
                  comment.body,
                  style: const TextStyle(fontSize: 14),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    _buildReactionButton(
                      context,
                      comment,
                      'like',
                      Icons.thumb_up_outlined,
                      Icons.thumb_up,
                    ),
                    const SizedBox(width: 16),
                    _buildReactionButton(
                      context,
                      comment,
                      'love',
                      Icons.favorite_border,
                      Icons.favorite,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactionButton(
    BuildContext context,
    CommentModel comment,
    String type,
    IconData outlinedIcon,
    IconData filledIcon,
  ) {
    final isSelected = comment.userReactionType == type;
    final count = comment.reactionCounts[type] ?? 0;

    return InkWell(
      onTap: () => onReaction(comment.id, type),
      child: Row(
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            size: 16,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
