import 'package:user_api/user_api.dart';

List<CategoryData> expensesCategoryData = <CategoryData>[
  const CategoryData(
    category: Category(
      id: '1',
      name: 'TRANSPORT',
      icon: 'DIRECTIONS_CAR',
      color: '#FF64B5F6',
      type: CategoryType.expense,
    ),
    value: 15000.75,
  ),
  const CategoryData(
    category: Category(
      id: '2',
      name: 'FEEDING',
      icon: 'RESTAURANT',
      color: '#FFFFB74D',
      type: CategoryType.expense,
    ),
    value: 27500.50,
  ),
  const CategoryData(
    category: Category(
      id: '3',
      name: 'HEALTH',
      icon: 'LOCAL_HOSPITAL',
      color: '#FF81C784',
      type: CategoryType.expense,
    ),
    value: 13000.25,
  ),
  const CategoryData(
    category: Category(
      id: '4',
      name: 'ENTERTAINMENT',
      icon: 'MOVIE',
      color: '#FFBA68C8',
      type: CategoryType.expense,
    ),
    value: 12000.73,
  ),
  const CategoryData(
    category: Category(
      id: '5',
      name: 'TRIPS',
      icon: 'CARD_TRAVEL',
      color: '#FFFFF176',
      type: CategoryType.expense,
    ),
    value: 22000.13,
  ),
  const CategoryData(
    category: Category(
      id: '6',
      name: 'TECHNOLOGY',
      icon: 'COMPUTER',
      color: '#FF4DD0E1',
      type: CategoryType.expense,
    ),
    value: 18000.38,
  ),
  const CategoryData(
    category: Category(
      id: '7',
      name: 'EDUCATION',
      icon: 'SCHOOL',
      color: '#FFFF7043',
      type: CategoryType.expense,
    ),
    value: 19000.80,
  ),
  const CategoryData(
    category: Category(
      id: '8',
      name: 'FASHION',
      icon: 'CHECKROOM',
      color: '#FFF48FB1',
      type: CategoryType.expense,
    ),
    value: 14000.84,
  ),
  const CategoryData(
    category: Category(
      id: '9',
      name: 'TAXES',
      icon: 'PAYMENTS',
      color: '#FF8BC34A',
      type: CategoryType.expense,
    ),
    value: 30000.63,
  ),
  const CategoryData(
    category: Category(
      id: '10',
      name: 'INSURANCE',
      icon: 'SECURITY',
      color: '#FF2196F3',
      type: CategoryType.expense,
    ),
    value: 25000.35,
  ),
  const CategoryData(
    category: Category(
      id: '11',
      name: 'DWELLING',
      icon: 'HOUSE',
      color: '#FFA1887F',
      type: CategoryType.expense,
    ),
    value: 32000.40,
  ),
  const CategoryData(
    category: Category(
      id: '12',
      name: 'OTHERS',
      icon: 'CATEGORY',
      color: '#FFBDBDBD',
      type: CategoryType.expense,
    ),
    value: 5000.94,
  ),
];

List<CategoryData> incomesCategoryData = <CategoryData>[
  const CategoryData(
    category: Category(
      id: '1',
      name: 'SALARY',
      icon: 'ATTACH_MONEY',
      color: '#FF64B5F6',
      type: CategoryType.income,
    ),
    value: 52345.67,
  ),
  const CategoryData(
    category: Category(
      id: '2',
      name: 'BUSINESS',
      icon: 'BUSINESS',
      color: '#FFFFB74D',
      type: CategoryType.income,
    ),
    value: 41234.56,
  ),
  const CategoryData(
    category: Category(
      id: '3',
      name: 'FREELANCE',
      icon: 'PERSON_SEARCH',
      color: '#FF81C784',
      type: CategoryType.income,
    ),
    value: 37890.12,
  ),
  const CategoryData(
    category: Category(
      id: '4',
      name: 'RENTALS',
      icon: 'APARTMENT',
      color: '#FFBA68C8',
      type: CategoryType.income,
    ),
    value: 28901.34,
  ),
  const CategoryData(
    category: Category(
      id: '5',
      name: 'INVESTMENTS',
      icon: 'TRENDING_UP',
      color: '#FFFFF176',
      type: CategoryType.income,
    ),
    value: 15789.45,
  ),
  const CategoryData(
    category: Category(
      id: '6',
      name: 'INTERESTS',
      icon: 'PERCENT',
      color: '#FF4DD0E1',
      type: CategoryType.income,
    ),
    value: 10987.65,
  ),
  const CategoryData(
    category: Category(
      id: '7',
      name: 'PENSIONS',
      icon: 'CARD_MEMBERSHIP',
      color: '#FFFF7043',
      type: CategoryType.income,
    ),
    value: 8765.43,
  ),
  const CategoryData(
    category: Category(
      id: '8',
      name: 'DIVIDENDS',
      icon: 'MONETIZATION_ON',
      color: '#FFF48FB1',
      type: CategoryType.income,
    ),
    value: 7654.32,
  ),
  const CategoryData(
    category: Category(
      id: '9',
      name: 'GIFTS',
      icon: 'CARD_GIFTCARD',
      color: '#FF8BC34A',
      type: CategoryType.income,
    ),
    value: 6543.21,
  ),
  const CategoryData(
    category: Category(
      id: '10',
      name: 'REFUNDS',
      icon: 'RECEIPT_LONG',
      color: '#FF2196F3',
      type: CategoryType.income,
    ),
    value: 5432.10,
  ),
  const CategoryData(
    category: Category(
      id: '11',
      name: 'SALES',
      icon: 'LOCAL_OFFER',
      color: '#FFA1887F',
      type: CategoryType.income,
    ),
    value: 4321.09,
  ),
  const CategoryData(
    category: Category(
      id: '12',
      name: 'OTHERS',
      icon: 'CATEGORY',
      color: '#FFBDBDBD',
      type: CategoryType.income,
    ),
    value: 3210.98,
  ),
];
