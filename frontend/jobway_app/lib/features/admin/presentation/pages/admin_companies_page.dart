import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/admin_provider.dart';
import '../widgets/company_moderation_card.dart';

class AdminCompaniesPage extends ConsumerStatefulWidget {
  const AdminCompaniesPage({super.key});

  @override
  ConsumerState<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends ConsumerState<AdminCompaniesPage> {
  String? _updatingId;

  Future<void> _verify(String id) async {
    setState(() => _updatingId = id);
    try {
      await ref.read(verifyCompanyUseCaseProvider).call(id);
      ref.invalidate(adminCompaniesProvider);
      AppSnackbar.showSuccess('Компания верифицирована');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  Future<void> _reject(String id) async {
    setState(() => _updatingId = id);
    try {
      await ref.read(rejectCompanyUseCaseProvider).call(id);
      ref.invalidate(adminCompaniesProvider);
      AppSnackbar.showSuccess('Заявка отклонена');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(adminCompaniesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Компании',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminCompaniesProvider),
        child: companiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(padding: const EdgeInsets.all(24), child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center)),
          ),
          data: (companies) => companies.isEmpty
              ? const Center(child: Text('Компаний пока нет', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    final company = companies[index];
                    return CompanyModerationCard(
                      company: company,
                      isUpdating: _updatingId == company.id,
                      onVerify: () => _verify(company.id),
                      onReject: () => _reject(company.id),
                    );
                  },
                ),
        ),
      ),
    );
  }
}