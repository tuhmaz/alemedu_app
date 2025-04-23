class ArabCountry {
  final String code;
  final String nameAr;
  final String nameEn;

  const ArabCountry({
    required this.code,
    required this.nameAr,
    required this.nameEn,
  });
}

const List<ArabCountry> arabCountries = [
  ArabCountry(code: 'SA', nameAr: 'المملكة العربية السعودية', nameEn: 'Saudi Arabia'),
  ArabCountry(code: 'AE', nameAr: 'الإمارات العربية المتحدة', nameEn: 'United Arab Emirates'),
  ArabCountry(code: 'KW', nameAr: 'الكويت', nameEn: 'Kuwait'),
  ArabCountry(code: 'BH', nameAr: 'البحرين', nameEn: 'Bahrain'),
  ArabCountry(code: 'QA', nameAr: 'قطر', nameEn: 'Qatar'),
  ArabCountry(code: 'OM', nameAr: 'عمان', nameEn: 'Oman'),
  ArabCountry(code: 'YE', nameAr: 'اليمن', nameEn: 'Yemen'),
  ArabCountry(code: 'IQ', nameAr: 'العراق', nameEn: 'Iraq'),
  ArabCountry(code: 'SY', nameAr: 'سوريا', nameEn: 'Syria'),
  ArabCountry(code: 'LB', nameAr: 'لبنان', nameEn: 'Lebanon'),
  ArabCountry(code: 'JO', nameAr: 'الأردن', nameEn: 'Jordan'),
  ArabCountry(code: 'PS', nameAr: 'فلسطين', nameEn: 'Palestine'),
  ArabCountry(code: 'EG', nameAr: 'مصر', nameEn: 'Egypt'),
  ArabCountry(code: 'SD', nameAr: 'السودان', nameEn: 'Sudan'),
  ArabCountry(code: 'LY', nameAr: 'ليبيا', nameEn: 'Libya'),
  ArabCountry(code: 'TN', nameAr: 'تونس', nameEn: 'Tunisia'),
  ArabCountry(code: 'DZ', nameAr: 'الجزائر', nameEn: 'Algeria'),
  ArabCountry(code: 'MA', nameAr: 'المغرب', nameEn: 'Morocco'),
  ArabCountry(code: 'MR', nameAr: 'موريتانيا', nameEn: 'Mauritania'),
  ArabCountry(code: 'SO', nameAr: 'الصومال', nameEn: 'Somalia'),
  ArabCountry(code: 'DJ', nameAr: 'جيبوتي', nameEn: 'Djibouti'),
  ArabCountry(code: 'KM', nameAr: 'جزر القمر', nameEn: 'Comoros'),
];
