/// A circle option the signed-in leader can switch to from the Dashboard.
class DashboardCircleOption {
  final String id;
  final String name;
  final String country;
  final String district;
  final String industry;
  final int peersCount;
  final String status;

  const DashboardCircleOption({
    required this.id,
    required this.name,
    this.country = '',
    this.district = '',
    this.industry = '',
    this.peersCount = 0,
    this.status = '',
  });
}
