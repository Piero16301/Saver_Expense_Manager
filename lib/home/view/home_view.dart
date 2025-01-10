import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/models/models.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
          child: Column(
            children: [
              CircularChartHome(),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularChartHome extends StatefulWidget {
  const CircularChartHome({super.key});

  @override
  State<CircularChartHome> createState() => _CircularChartHomeState();
}

class _CircularChartHomeState extends State<CircularChartHome> {
  late TooltipBehavior _tooltipBehavior;
  late List<ChartData> _chartData;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      animationDuration: 500,
      duration: 1000,
    );
    _chartData = <ChartData>[
      const ChartData(
        id: '1',
        name: 'Transporte',
        value: 50,
      ),
      const ChartData(
        id: '2',
        name: 'Entretenimiento',
        value: 75,
      ),
      const ChartData(
        id: '3',
        name: 'Salud',
        value: 30,
      ),
      const ChartData(
        id: '4',
        name: 'Educación',
        value: 90,
      ),
      const ChartData(
        id: '5',
        name: 'Vivienda',
        value: 120,
      ),
      const ChartData(
        id: '6',
        name: 'Ropa',
        value: 45,
      ),
      const ChartData(
        id: '7',
        name: 'Viajes',
        value: 60,
      ),
      const ChartData(
        id: '8',
        name: 'Regalos',
        value: 20,
      ),
      const ChartData(
        id: '9',
        name: 'Mascotas',
        value: 35,
      ),
      const ChartData(
        id: '10',
        name: 'Otros',
        value: 25,
      ),
    ];
    super.initState();
  }

  @override
  void dispose() {
    _chartData.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
      ),
      series: _buildDoughnutSeries(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  List<DoughnutSeries<ChartData, String>> _buildDoughnutSeries() {
    return <DoughnutSeries<ChartData, String>>[
      DoughnutSeries<ChartData, String>(
        dataSource: _chartData,
        xValueMapper: (ChartData data, _) => data.name,
        yValueMapper: (ChartData data, _) => data.value,
        dataLabelMapper: (ChartData data, _) => data.name,
        animationDuration: 500,
        innerRadius: '40%',
        legendIconType: LegendIconType.diamond,
        explode: true,
        explodeIndex: 0,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
        ),
      ),
    ];
  }
}
