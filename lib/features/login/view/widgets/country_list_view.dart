import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'country_list_tile.dart';

/// Renders the list of selectable countries with selection indicators.
class CountryListView extends StatelessWidget {
  final List<Country> countries;
  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const CountryListView({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (countries.isEmpty) {
      return const Center(
        child: Text(
          'No countries found',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: countries.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 48,
        color: Color(0xFFF8FAFC),
      ),
      itemBuilder: (context, index) {
        final country = countries[index];
        return CountryListTile(
          country: country,
          isSelected: country.countryCode == selectedCountry.countryCode,
          onTap: () => onCountrySelected(country),
        );
      },
    );
  }
}
