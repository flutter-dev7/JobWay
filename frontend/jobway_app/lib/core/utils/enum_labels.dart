import 'package:flutter/material.dart';

String employmentTypeLabel(String type) => switch (type) {
      'FullTime' => 'Полная занятость',
      'PartTime' => 'Частичная занятость',
      'Remote' => 'Удалённо',
      'Internship' => 'Стажировка',
      _ => type,
    };

String experienceLevelLabel(String level) => switch (level) {
      'NoExperience' => 'Без опыта',
      'Junior' => 'Junior',
      'Middle' => 'Middle',
      'Senior' => 'Senior',
      _ => level,
    };

String applicationStatusLabel(String status) => switch (status) {
      'Pending' => 'На рассмотрении',
      'Viewed' => 'Просмотрено',
      'Interview' => 'Собеседование',
      'Accepted' => 'Принято',
      'Rejected' => 'Отклонено',
      _ => status,
    };

Color applicationStatusColor(String status) => switch (status) {
      'Accepted' => const Color(0xFF059669),
      'Rejected' => const Color(0xFFDC2626),
      'Interview' => const Color(0xFF3157D5),
      'Viewed' => const Color(0xFFD97706),
      _ => const Color(0xFF6B7280),
    };