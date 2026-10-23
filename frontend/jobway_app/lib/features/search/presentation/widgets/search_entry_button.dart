import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../pages/candidate_search_page.dart';
import '../pages/company_search_page.dart';

class SearchEntryButton extends StatelessWidget {
  // true: работодатель ищет кандидатов, false: кандидат ищет компании
  final bool forEmployer;

  const SearchEntryButton({super.key, required this.forEmployer});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: IconButton(
        tooltip: forEmployer ? 'Поиск кандидатов' : 'Поиск компаний',
        style: IconButton.styleFrom(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(
          forEmployer ? Icons.person_search_rounded : Icons.domain_rounded,
          size: 21,
          color: colors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                forEmployer ? const CandidateSearchPage() : const CompanySearchPage(),
          ),
        ),
      ),
    );
  }
}