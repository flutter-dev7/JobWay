import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../domain/entities/review.dart';
import '../providers/reviews_controller.dart';
import '../providers/reviews_provider.dart';

class AllReviewsPage extends ConsumerStatefulWidget {
  final String userId;

  const AllReviewsPage({super.key, required this.userId});

  @override
  ConsumerState<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends ConsumerState<AllReviewsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ReviewsController get _controller =>
      ref.read(reviewsControllerProvider(widget.userId).notifier);

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  Widget _buildHeader(ReviewsState state) {
    final colors = context.colors;
    final average =
        ref.watch(averageRatingProvider(widget.userId)).valueOrNull ?? 0;
    final total = state.totalCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 26),
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
            '($total ${total == 1 ? "отзыв" : "отзывов"})',
            style: TextStyle(fontSize: 14, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final colors = context.colors;
    final hasPhoto =
        review.reviewerPhotoUrl != null && review.reviewerPhotoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03,
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
                  image: hasPhoto
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
                child: !hasPhoto
                    ? Center(
                        child: Text(
                          review.reviewerName.trim().isNotEmpty
                              ? review.reviewerName.trim()[0].toUpperCase()
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
                style: TextStyle(fontSize: 11, color: colors.textMuted),
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
          if (review.comment != null && review.comment!.isNotEmpty) ...[
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
    );
  }

  Widget _buildBody(ReviewsState state) {
    final colors = context.colors;

    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Text(state.error!, textAlign: TextAlign.center),
        ],
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _buildHeader(state),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Пока нет отзывов',
                style: TextStyle(fontSize: 14, color: colors.textMuted),
              ),
            ),
          ),
        ],
      );
    }

    // Индекс 0 — шапка с рейтингом, дальше отзывы, в конце индикатор подгрузки
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: state.items.length + 1 + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader(state);

        final reviewIndex = index - 1;
        if (reviewIndex >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildReviewCard(state.items[reviewIndex]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewsControllerProvider(widget.userId));
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Отзывы'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(averageRatingProvider(widget.userId));
          await _controller.load();
        },
        child: _buildBody(state),
      ),
    );
  }
}
