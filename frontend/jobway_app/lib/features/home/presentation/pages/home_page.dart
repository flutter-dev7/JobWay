// features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:jobway_app/features/applications/presentation/pages/my_applications_page.dart';
import 'package:jobway_app/features/candidate_profile/presentation/pages/candidate_profile_page.dart';
import 'package:jobway_app/features/company_profile/presentation/pages/company_profile_page.dart';
import 'package:jobway_app/features/vacancies/presentation/pages/vacancies_list_page.dart';
import '../../../../core/widgets/floating_nav_bar.dart';

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<FloatingNavItem> _navItems = widget.role == 'Employer'
      ? [
          FloatingNavItem(icon: Icons.work_outline, label: 'Вакансии'),
          FloatingNavItem(icon: Icons.people_outline, label: 'Отклики'),
          FloatingNavItem(icon: Icons.business_outlined, label: 'Компания'),
        ]
      : [
          FloatingNavItem(icon: Icons.search, label: 'Вакансии'),
          FloatingNavItem(icon: Icons.assignment_outlined, label: 'Отклики'),
          FloatingNavItem(icon: Icons.person_outline, label: 'Профиль'),
        ];

  late final List<Widget> _pages = widget.role == 'Employer'
      ? [
          const _PlaceholderPage(title: 'Мои вакансии'),
          const _PlaceholderPage(title: 'Отклики'),
          const CompanyProfilePage(),
        ]
      : [
          const VacanciesListPage(),
          const MyApplicationsPage(),
          const CandidateProfilePage(),
        ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + 16,
            child: Center(
              child: FloatingNavBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                items: _navItems,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }
}
