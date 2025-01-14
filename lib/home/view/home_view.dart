import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' hide Image;
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/models/models.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo_no_bg.png', height: 40),
        centerTitle: true,
        leading: const ChangeThemeButton(),
        actions: [
          IconButton(
            icon: user?.photoURL == null
                ? const Icon(Icons.person)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(highResPicture(user!.photoURL)),
                  ),
            onPressed: () => context.pushNamed('profile'),
          ),
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Placeholder(),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarHome(),
    );
  }
}

class BottomNavigationBarHome extends StatefulWidget {
  const BottomNavigationBarHome({super.key});

  @override
  State<BottomNavigationBarHome> createState() =>
      _BottomNavigationBarHomeState();
}

class _BottomNavigationBarHomeState extends State<BottomNavigationBarHome> {
  List<SMIBool> riveIconInputs = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _buildNavItems(context).length,
            (index) {
              final riveIcon = _buildNavItems(context)[index].rive;
              return GestureDetector(
                onTap: () {
                  riveIconInputs[index].change(true);
                  Future<void>.delayed(
                    const Duration(seconds: 1),
                    () => riveIconInputs[index].change(false),
                  );
                  context.read<HomeCubit>().toggleSelectedIndex(index);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 2),
                      height: 4,
                      width: state.selectedIndex == index ? 20 : 0,
                      decoration: BoxDecoration(
                        color: state.selectedIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    SizedBox.square(
                      dimension: 30,
                      child: Opacity(
                        opacity: state.selectedIndex == index ? 1 : 0.7,
                        child: RiveAnimation.asset(
                          riveIcon.src,
                          artboard: riveIcon.artboard,
                          onInit: (artboard) {
                            final controller =
                                StateMachineController.fromArtboard(
                              artboard,
                              riveIcon.stateMachineName,
                            );
                            artboard.addController(controller!);
                            riveIconInputs.add(
                              controller.findInput<bool>('hover')! as SMIBool,
                            );
                          },
                        ),
                      ),
                    ),
                    Text(
                      _buildNavItems(context)[index].title,
                      style: TextStyle(
                        color: state.selectedIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                        fontWeight: state.selectedIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<NavItem> _buildNavItems(BuildContext context) {
    final l10n = context.l10n;

    return [
      NavItem(
        title: l10n.homeExpensesTitle,
        rive: RiveSrc(
          src: 'assets/animations/animated-icons.riv',
          artboard: 'arrow-down',
          stateMachineName: 'State Machine 1',
        ),
      ),
      NavItem(
        title: l10n.homeIncomeTitle,
        rive: RiveSrc(
          src: 'assets/animations/animated-icons.riv',
          artboard: 'arrow-up',
          stateMachineName: 'arrowUP',
        ),
      ),
    ];
  }
}
