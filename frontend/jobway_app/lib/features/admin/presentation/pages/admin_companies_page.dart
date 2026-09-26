// features/admin/presentation/pages/admin_companies_page.dart — заменить целиком
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../domain/entities/company_moderation.dart';
import '../providers/admin_provider.dart';
import '../widgets/company_moderation_card.dart';

class AdminCompaniesPage extends ConsumerStatefulWidget {
  const AdminCompaniesPage({super.key});

  @override
  ConsumerState<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends ConsumerState<AdminCompaniesPage> {
  String? _updatingId;
  int _selectedFilter = 0;

  static const _filters = ['Все', 'На рассмотрении', 'Верифицированы', 'Отклонены'];
  static const _filterStatuses = [null, 'NotVerified', 'Verified', 'Rejected'];

  List<CompanyModeration> _filtered(List<CompanyModeration> all) {
    final status = _filterStatuses[_selectedFilter];
    if (status == null) return all;
    return all.where((c) => c.verificationStatus == status).toList();
  }

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
      body: companiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center)),
        ),
        data: (companies) {
          final filtered = _filtered(companies);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminCompaniesProvider),
            child: Column(
              children: [
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilter == index;
                      final count = index == 0
                          ? companies.length
                          : companies.where((c) => c.verificationStatus == _filterStatuses[index]).length;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF111827) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_filters[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF374151),
                                  )),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('$count',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                      )),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Компаний нет', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final company = filtered[index];
                            return CompanyModerationCard(
                              company: company,
                              isUpdating: _updatingId == company.id,
                              onVerify: () => _verify(company.id),
                              onReject: () => _reject(company.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}