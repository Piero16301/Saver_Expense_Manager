import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class AppVariables {
  static const String appName = 'Saver';

  @visibleForTesting
  static bool useTestFonts = false;

  static const Color defaultBaseColor = Colors.green;
  static const String defaultFontFamily = 'GoogleSansFlex';
  static const List<String> allowedExtensions = ['pdf', 'png', 'jpg', 'jpeg'];
  static const List<String> imageExtensions = ['png', 'jpg', 'jpeg'];
  static const String unsupportedLocalModelFile =
      'UNSUPPORTED_LOCAL_MODEL_FILE';

  static final minDate = DateTime(2020);
  static const deafultMonthsTrend = 10;
  static const maxDaysWarning = 7;
  static const tabletMaxWidth = 500.0;
  static const tabletMaxHeight = 400.0;

  static const animationDuration = Duration(milliseconds: 400);
  static const snackBarDuration = Duration(seconds: 5);
  static const timeoutDuration = Duration(seconds: 5);
  static const remoteConfigFetchTimeout = Duration(minutes: 1);
  static const remoteConfigMinimumFetchInterval = Duration(hours: 1);

  static final DateFormat formatDate = DateFormat('dd/MM/yyyy');

  static const String expensesTab = 'gastos';
  static const String movementsTab = 'movimientos';
  static const String summaryTab = 'resumen';
  static const String incomesTab = 'ingresos';

  static const String googleProvider = 'google.com';
  static const String emailProvider = 'password';

  static const String nameRegExp =
      r'^(?=.{2,}$)[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+(?: [a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+)*$';
  static const String emailRegExp =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordRegExp = r'^(?=.*[a-z])(?=.*[A-Z]).{6,}$';

  static const MaterialAccentColor incomeColor = Colors.blueAccent;
  static const MaterialColor balanceColor = Colors.teal;
  static const MaterialAccentColor expenseColor = Colors.orangeAccent;

  static const MaterialColor growthColor = Colors.green;
  static const MaterialAccentColor decreaseColor = Colors.redAccent;

  static Map<String, String> availableFonts = getAvailableFonts();

  static Map<String, String> getAvailableFonts() {
    return {
      'Google Sans Flex': 'GoogleSansFlex',
      'Merriweather': 'Merriweather',
      'Montserrat': 'Montserrat',
      'Nunito': 'Nunito',
      'Open Sans': 'OpenSans',
      'Orbitron': 'Orbitron',
      'Playfair Display': 'PlayfairDisplay',
      'Roboto': 'Roboto',
      'Source Code Pro': 'SourceCodePro',
    };
  }

  static const categoriesCollection = 'categories';
  static const movementsCollection = 'movements';
  static const usersCollection = 'users';

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('it', 'IT'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
    Locale('pt', 'PT'),
  ];

  static const Map<String, Locale> deviceLanguageMap = {
    'en': Locale('en', 'US'),
    'es': Locale('es', 'ES'),
    'it': Locale('it', 'IT'),
    'fr': Locale('fr', 'FR'),
    'de': Locale('de', 'DE'),
    'pt': Locale('pt', 'PT'),
  };
}

enum SnackBarType {
  success,
  error,
  warning,
  info;

  bool get isSuccess => this == SnackBarType.success;
  bool get isError => this == SnackBarType.error;
  bool get isWarning => this == SnackBarType.warning;
  bool get isInfo => this == SnackBarType.info;
}

enum MovementScreenType { add, edit }

enum ImageResolutionType { low, medium, high }

enum ResumeItemType { income, expense, balance }

enum ModelType {
  cloud,
  local;

  bool get isCloud => this == ModelType.cloud;
  bool get isLocal => this == ModelType.local;

  String get name {
    switch (this) {
      case ModelType.cloud:
        return 'CLOUD';
      case ModelType.local:
        return 'LOCAL';
    }
  }

  static ModelType fromName(String name) {
    switch (name) {
      case 'CLOUD':
        return ModelType.cloud;
      case 'LOCAL':
        return ModelType.local;
      default:
        return ModelType.cloud;
    }
  }
}
