import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final categories = context
        .select<AppCubit, List<Category>>((cubit) => cubit.state.categories);

    if (categories.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/logo_no_bg.png', height: 40),
          centerTitle: true,
          notificationPredicate: (notification) => false,
          leading: const ChangeThemeButton(),
          actions: [
            IconButton(
              icon: user?.photoURL == null
                  ? const Icon(Icons.person)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(highResPicture(user!.photoURL)!),
                    ),
              onPressed: () => context.pushNamed('profile'),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: _getSelectedBody(state.selectedIndex),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavigationBarHome(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (context) => const AddMovementBottomSheet(),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _getSelectedBody(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const ExpensesHomePage();
      case 1:
        return const MovementsHomePage();
      case 2:
        return const IncomeHomePage();
      default:
        return const SizedBox.shrink();
    }
  }
}

class BottomNavigationBarHome extends StatelessWidget {
  const BottomNavigationBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => NavigationBar(
        selectedIndex: state.selectedIndex,
        onDestinationSelected: (index) =>
            context.read<HomeCubit>().toggleSelectedIndex(index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.money_off_outlined),
            selectedIcon: const Icon(Icons.money_off),
            label: l10n.homeExpensesTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: l10n.homeMovementsTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.attach_money_outlined),
            selectedIcon: const Icon(Icons.attach_money),
            label: l10n.homeIncomeTitle,
          ),
        ],
      ),
    );
  }
}

class AddMovementBottomSheet extends StatelessWidget {
  const AddMovementBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final locale =
        context.select<AppCubit, Locale>((cubit) => cubit.state.locale!);
    final model = context
        .select<AppCubit, GenerativeModel>((cubit) => cubit.state.model!);
    final categories = context
        .select<AppCubit, List<Category>>((cubit) => cubit.state.categories)
        .toList();

    return Container(
      width: double.infinity,
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonTheme.colorScheme!.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.homeAddExpense,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            spacing: 10,
            children: [
              TonalButtonActionHome(
                title: context.l10n.homeFile,
                icon: Icons.upload_file,
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                  );
                  if (result != null) {
                    final file = result.files.single;
                    final movement = await buildMovementFromFile(
                      model: model,
                      type: expenseType,
                      categories: categories
                          .where((c) => c.type == CategoryType.expense)
                          .toList(),
                      languageCode: locale.languageCode,
                      mimeType: lookupMimeType(file.name) ?? 'application/pdf',
                      bytes: await file.xFile.readAsBytes(),
                    );

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    await context.pushNamed(
                      'movement',
                      pathParameters: {
                        'type': expenseType,
                        'screenType': 'ADD',
                      },
                      extra: movement,
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
              ),
              TonalButtonActionHome(
                title: context.l10n.homeScan,
                icon: Icons.document_scanner,
                onPressed: () {},
              ),
              TonalButtonActionHome(
                title: context.l10n.homeFill,
                icon: Icons.edit,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(
                    'movement',
                    pathParameters: {
                      'type': expenseType,
                      'screenType': 'ADD',
                    },
                    extra: Movement.empty,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            context.l10n.homeAddIncome,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            spacing: 10,
            children: [
              TonalButtonActionHome(
                title: context.l10n.homeFile,
                icon: Icons.upload_file,
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                  );
                  if (result != null) {
                    final file = result.files.single;
                    final movement = await buildMovementFromFile(
                      model: model,
                      type: incomeType,
                      categories: categories
                          .where((c) => c.type == CategoryType.income)
                          .toList(),
                      languageCode: locale.languageCode,
                      mimeType: lookupMimeType(file.name) ?? 'application/pdf',
                      bytes: await file.xFile.readAsBytes(),
                    );

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    await context.pushNamed(
                      'movement',
                      pathParameters: {
                        'type': incomeType,
                        'screenType': 'ADD',
                      },
                      extra: movement,
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
              ),
              TonalButtonActionHome(
                title: context.l10n.homeScan,
                icon: Icons.document_scanner,
                onPressed: () {},
              ),
              TonalButtonActionHome(
                title: context.l10n.homeFill,
                icon: Icons.edit,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(
                    'movement',
                    pathParameters: {
                      'type': incomeType,
                      'screenType': 'ADD',
                    },
                    extra: Movement.empty,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TonalButtonActionHome extends StatelessWidget {
  const TonalButtonActionHome({
    required this.title,
    required this.icon,
    this.onPressed,
    super.key,
  });

  final String title;
  final IconData icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: FilledButton.tonal(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 7.5),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            spacing: 5,
            children: [
              Icon(icon, size: 25),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
