import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/utils/time_ago.dart';
import '../pages/all_reviews_page.dart';
import '../providers/reviews_provider.dart';

class ReviewsSection extends ConsumerWidget {
  final String userId;
  static const _previewCount = 2;

  const ReviewsSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averageAsync = ref.watch(averageRatingProvider(userId));
    final reviewsAsync = ref.watch(reviewsForUserProvider(userId));

    return SectionCard(
      title: 'Отзывы',
      icon: Icons.star_outline_rounded,
      child: reviewsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, _) => Text(
          ApiException.extractMessage(error),
          style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        ),
        data: (reviews) {
          final average = averageAsync.valueOrNull ?? 0;
          final preview = reviews.take(_previewCount).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    average.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${reviews.length} ${reviews.length == 1 ? "отзыв" : "отзывов"})',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              if (preview.isEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Пока нет отзывов',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ] else ...[
                const SizedBox(height: 14),
                ...preview.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F5FF),
                                shape: BoxShape.circle,
                                image:
                                    review.reviewerPhotoUrl != null &&
                                        review.reviewerPhotoUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          '${ApiConstants.fileBaseUrl}${review.reviewerPhotoUrl}',
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  review.reviewerPhotoUrl == null ||
                                      review.reviewerPhotoUrl!.isEmpty
                                  ? Center(
                                      child: Text(
                                        review.reviewerName.trim().isNotEmpty
                                            ? review.reviewerName
                                                  .trim()[0]
                                                  .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF3157D5),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                review.reviewerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < review.rating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 16,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              TimeAgo.format(review.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                        if (review.comment != null &&
                            review.comment!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            review.comment!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (reviews.length > _previewCount)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllReviewsPage(userId: userId),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Все отзывы (${reviews.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3157D5),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFF3157D5),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
