import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../providers/admin_provider.dart';
import 'admin_company_detail_page.dart';

class AdminCompanyLoaderPage extends ConsumerWidget {
  final String companyId;

  const AdminCompanyLoaderPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyAsync = ref.watch(adminCompanyByIdProvider(companyId));

    return companyAsync.when(
      data: (company) => AdminCompanyDetailPage(company: company),
      loading: () => Scaffold(
        backgroundColor: context.colors.background,
        appBar: appPageAppBar(context, 'Профиль компании'),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: context.colors.background,
        appBar: appPageAppBar(context, 'Профиль компании'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ApiException.extractMessage(error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}