import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: appPageAppBar(context, 'Отзывы'),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center),
          ),
        ),
        data: (reviews) {
          final average = averageAsync.valueOrNull ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 26),
                  const SizedBox(width: 8),
                  Text(
                    average.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${reviews.length} ${reviews.length == 1 ? "отзыв" : "отзывов"})',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('Пока нет отзывов', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
                  ),
                )
              else
                ...reviews.map((review) => Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
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
                                  color: const Color(0xFFF3F5FF),
                                  shape: BoxShape.circle,
                                  image: review.reviewerPhotoUrl != null && review.reviewerPhotoUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage('${ApiConstants.fileBaseUrl}${review.reviewerPhotoUrl}'),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: review.reviewerPhotoUrl == null || review.reviewerPhotoUrl!.isEmpty
                                    ? Center(
                                        child: Text(
                                          review.reviewerName.trim().isNotEmpty ? review.reviewerName.trim()[0].toUpperCase() : '?',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF3157D5)),
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
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                                ),
                              ),
                              Text(
                                TimeAgo.format(review.createdAt),
                                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(5, (i) => Icon(
                                  i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                  size: 16,
                                  color: const Color(0xFFF59E0B),
                                )),
                          ),
                          if (review.comment != null && review.comment!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              review.comment!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.5),
                            ),
                          ],
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}