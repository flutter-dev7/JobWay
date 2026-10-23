class CandidateSearchItem {
  final String id;
  final String fullName;
  final String? photoUrl;
  final String? location;
  final String experienceLevel;
  final List<String> topSkills;

  const CandidateSearchItem({
    required this.id,
    required this.fullName,
    this.photoUrl,
    this.location,
    required this.experienceLevel,
    required this.topSkills,
  });
}