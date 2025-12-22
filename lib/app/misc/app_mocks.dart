import 'package:user_api/user_api.dart';

class AppMocks {
  static const List<CategoryData> expensesCategoryData = <CategoryData>[
    CategoryData(
      category: Category(
        id: '1',
        name: 'TRANSPORT',
        icon: 'DIRECTIONS_CAR',
        color: '#FF64B5F6',
        type: CategoryType.expense,
      ),
      value: 15000.75,
    ),
    CategoryData(
      category: Category(
        id: '2',
        name: 'FEEDING',
        icon: 'RESTAURANT',
        color: '#FFFFB74D',
        type: CategoryType.expense,
      ),
      value: 27500.50,
    ),
    CategoryData(
      category: Category(
        id: '3',
        name: 'HEALTH',
        icon: 'LOCAL_HOSPITAL',
        color: '#FF81C784',
        type: CategoryType.expense,
      ),
      value: 13000.25,
    ),
    CategoryData(
      category: Category(
        id: '4',
        name: 'ENTERTAINMENT',
        icon: 'MOVIE',
        color: '#FFBA68C8',
        type: CategoryType.expense,
      ),
      value: 12000.73,
    ),
    CategoryData(
      category: Category(
        id: '5',
        name: 'TRIPS',
        icon: 'CARD_TRAVEL',
        color: '#FFFFF176',
        type: CategoryType.expense,
      ),
      value: 22000.13,
    ),
    CategoryData(
      category: Category(
        id: '6',
        name: 'TECHNOLOGY',
        icon: 'COMPUTER',
        color: '#FF4DD0E1',
        type: CategoryType.expense,
      ),
      value: 18000.38,
    ),
    CategoryData(
      category: Category(
        id: '7',
        name: 'EDUCATION',
        icon: 'SCHOOL',
        color: '#FFFF7043',
        type: CategoryType.expense,
      ),
      value: 19000.80,
    ),
    CategoryData(
      category: Category(
        id: '8',
        name: 'FASHION',
        icon: 'CHECKROOM',
        color: '#FFF48FB1',
        type: CategoryType.expense,
      ),
      value: 14000.84,
    ),
    CategoryData(
      category: Category(
        id: '9',
        name: 'TAXES',
        icon: 'PAYMENTS',
        color: '#FF8BC34A',
        type: CategoryType.expense,
      ),
      value: 30000.63,
    ),
    CategoryData(
      category: Category(
        id: '10',
        name: 'INSURANCE',
        icon: 'SECURITY',
        color: '#FF2196F3',
        type: CategoryType.expense,
      ),
      value: 25000.35,
    ),
    CategoryData(
      category: Category(
        id: '11',
        name: 'DWELLING',
        icon: 'HOUSE',
        color: '#FFA1887F',
        type: CategoryType.expense,
      ),
      value: 32000.40,
    ),
    CategoryData(
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

  static const List<CategoryData> incomesCategoryData = <CategoryData>[
    CategoryData(
      category: Category(
        id: '1',
        name: 'SALARY',
        icon: 'ATTACH_MONEY',
        color: '#FF64B5F6',
        type: CategoryType.income,
      ),
      value: 52345.67,
    ),
    CategoryData(
      category: Category(
        id: '2',
        name: 'BUSINESS',
        icon: 'BUSINESS',
        color: '#FFFFB74D',
        type: CategoryType.income,
      ),
      value: 41234.56,
    ),
    CategoryData(
      category: Category(
        id: '3',
        name: 'FREELANCE',
        icon: 'PERSON_SEARCH',
        color: '#FF81C784',
        type: CategoryType.income,
      ),
      value: 37890.12,
    ),
    CategoryData(
      category: Category(
        id: '4',
        name: 'RENTALS',
        icon: 'APARTMENT',
        color: '#FFBA68C8',
        type: CategoryType.income,
      ),
      value: 28901.34,
    ),
    CategoryData(
      category: Category(
        id: '5',
        name: 'INVESTMENTS',
        icon: 'TRENDING_UP',
        color: '#FFFFF176',
        type: CategoryType.income,
      ),
      value: 15789.45,
    ),
    CategoryData(
      category: Category(
        id: '6',
        name: 'INTERESTS',
        icon: 'PERCENT',
        color: '#FF4DD0E1',
        type: CategoryType.income,
      ),
      value: 10987.65,
    ),
    CategoryData(
      category: Category(
        id: '7',
        name: 'PENSIONS',
        icon: 'CARD_MEMBERSHIP',
        color: '#FFFF7043',
        type: CategoryType.income,
      ),
      value: 8765.43,
    ),
    CategoryData(
      category: Category(
        id: '8',
        name: 'DIVIDENDS',
        icon: 'MONETIZATION_ON',
        color: '#FFF48FB1',
        type: CategoryType.income,
      ),
      value: 7654.32,
    ),
    CategoryData(
      category: Category(
        id: '9',
        name: 'GIFTS',
        icon: 'CARD_GIFTCARD',
        color: '#FF8BC34A',
        type: CategoryType.income,
      ),
      value: 6543.21,
    ),
    CategoryData(
      category: Category(
        id: '10',
        name: 'REFUNDS',
        icon: 'RECEIPT_LONG',
        color: '#FF2196F3',
        type: CategoryType.income,
      ),
      value: 5432.10,
    ),
    CategoryData(
      category: Category(
        id: '11',
        name: 'SALES',
        icon: 'LOCAL_OFFER',
        color: '#FFA1887F',
        type: CategoryType.income,
      ),
      value: 4321.09,
    ),
    CategoryData(
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
}
