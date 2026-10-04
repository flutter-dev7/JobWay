import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../providers/reviews_provider.dart';

class AllReviewsPage extends ConsumerWidget {
  final String userId;

  const AllReviewsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsForUserProvider(userId));
    final averageAsync = ref.watch(averageRatingProvider(userId));
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Отзывы'),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ApiException.extractMessage(error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (reviews) {
          final average = averageAsync.valueOrNull ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    average.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${reviews.length} ${reviews.length == 1 ? "отзыв" : "отзывов"})',
                    style: TextStyle(fontSize: 14, color: colors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'Пока нет отзывов',
                      style: TextStyle(fontSize: 14, color: colors.textMuted),
                    ),
                  ),
                )
              else
                ...reviews.map(
                  (review) => Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            Theme.of(context).brightness == Brightness.dark
                                ? 0.2
                                : 0.03,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.surfaceMuted,
                                shape: BoxShape.circle,
                                image:
                                    review.reviewerPhotoUrl != null &&
                                        review.reviewerPhotoUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          ApiConstants.resolveFileUrl(
                                            review.reviewerPhotoUrl!,
                                          ),
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
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: context.accentColor,
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
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              TimeAgo.format(review.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 16,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        if (review.comment != null &&
                            review.comment!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            review.comment!,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
