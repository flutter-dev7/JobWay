import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../providers/search_list_controller.dart';

class SearchResultsBody<T> extends StatelessWidget {
  final SearchState<T> state;
  final ScrollController scrollController;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;

  const SearchResultsBody({
    super.key,
    required this.state,
    required this.scrollController,
    required this.itemBuilder,
    required this.onRefresh,
    required this.emptyIcon,
    required this.emptyTitle,
    this.emptySubtitle,
  });

  Widget _buildBody() {
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
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return itemBuilder(context, state.items[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, child: _buildBody());
  }
}