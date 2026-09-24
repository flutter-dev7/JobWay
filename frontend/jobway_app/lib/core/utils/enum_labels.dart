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