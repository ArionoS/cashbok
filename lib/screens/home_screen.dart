import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cashbook/models/transaction.dart';
import 'package:cashbook/screens/login_screen.dart';
import 'package:cashbook/services/authentication_service.dart';
import 'package:cashbook/services/data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.authService,
    required this.dataService,
  }) : super(key: key);

  static const String routeName = '/home';
  final AuthenticationService authService;
  final DataService dataService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Transaction>> transactions = Future.value([]);

  @override
  void initState() {
    super.initState();
    transactions = widget.dataService.getTransactions().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cash Book'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await widget.authService.logout();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              FutureBuilder<List<Transaction>>(
                future: transactions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              size: 100,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Error loading transactions',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 100,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No transactions yet',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final transactionData = snapshot.data!;
                    return Column(
                      children: [
                        _summaryContainer(transactionData),
                        _chartContainer(transactionData),
                      ],
                    );
                  }
                },
              ),
              _gridMenuContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryContainer(List<Transaction> transactions) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double totalBalance = 0.0;

    for (final transaction in transactions) {
      if (transaction.type == 'Income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    totalBalance = totalIncome - totalExpense;

    String totalIncomeString = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(totalIncome);
    String totalExpenseString = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(totalExpense);
    String totalBalanceString = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(totalBalance);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Income',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalIncomeString,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.arrow_upward,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalBalanceString,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Expense',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalExpenseString,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.arrow_downward,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartContainer(List<Transaction> transactions) {
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];

    for (final transaction in transactions) {
      if (transaction.type == 'Income') {
        incomeSpots.add(FlSpot(
          transaction.date.millisecondsSinceEpoch.toDouble(),
          transaction.amount.toDouble(),
        ));
      } else {
        expenseSpots.add(FlSpot(
          transaction.date.millisecondsSinceEpoch.toDouble(),
          transaction.amount.toDouble(),
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                  ),
                ),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      getTitlesWidget: leftTitleWidgets,
                      showTitles: true,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 2),
                    left: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 2),
                    right: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 2),
                    top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 2),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                    spots: incomeSpots,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.pink,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: false,
                      color: Colors.pink.withOpacity(0),
                    ),
                    spots: expenseSpots,
                  ),
                ],
                minX: _getMinX(transactions),
                maxX: _getMaxX(transactions),
                minY: _getMinY(transactions),
                maxY: _getMaxY(transactions),
              ),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 7,
    );
    Widget text;

    String formattedDate = DateFormat('dd/MMM')
        .format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));

    text = Text(
      formattedDate,
      style: style,
      textAlign: TextAlign.center,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 7,
    );
    String text;

    if (value >= 1000000000) {
      text = '${NumberFormat.compactCurrency(
        locale: 'id',
        symbol: 'Rp. ',
        decimalDigits: 0,
      ).format(value / 1000000000)}B';
    } else if (value >= 1000000) {
      text = '${NumberFormat.compactCurrency(
        locale: 'id',
        symbol: 'Rp. ',
        decimalDigits: 0,
      ).format(value / 1000000)}M';
    } else if (value >= 1000) {
      text = '${NumberFormat.compactCurrency(
        locale: 'id',
        symbol: 'Rp. ',
        decimalDigits: 0,
      ).format(value / 1000)}K';
    } else {
      text = NumberFormat.compactCurrency(
        locale: 'id',
        symbol: 'Rp. ',
        decimalDigits: 0,
      ).format(value);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }

  double _getMaxX(List<Transaction> transactions) {
    double max = 0;
    for (final transaction in transactions) {
      if (transaction.date.millisecondsSinceEpoch.toDouble() > max) {
        max = transaction.date.millisecondsSinceEpoch.toDouble();
      }
    }
    max = max + 86400000;
    return max;
  }

  double _getMinX(List<Transaction> transactions) {
    double min = double.infinity;
    for (final transaction in transactions) {
      if (transaction.date.millisecondsSinceEpoch.toDouble() < min) {
        min = transaction.date.millisecondsSinceEpoch.toDouble();
      }
    }

    min = min - 86400000;
    return min;
  }

  double _getMaxY(List<Transaction> transactions) {
    double max = 0;
    for (final transaction in transactions) {
      if (transaction.amount.toDouble() > max) {
        max = transaction.amount.toDouble();
      }
    }
    max = max + 100000;
    return max;
  }

  double _getMinY(List<Transaction> transactions) {
    double min = double.infinity;
    for (final transaction in transactions) {
      if (transaction.amount.toDouble() < min) {
        min = transaction.amount.toDouble();
      }
    }

    min = min - 100000;
    if (min == double.infinity) {
      min = 0;
    }
    return min;
  }

  Widget _gridMenuContainer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            children: [
              _gridMenuItem(
                icon: Icons.add,
                label: 'Income',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/add_transaction',
                  arguments: 'Income',
                ),
              ),
              _gridMenuItem(
                icon: Icons.remove,
                label: 'Expense',
                color: Colors.pink,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/add_transaction',
                  arguments: 'Expense',
                ),
              ),
              _gridMenuItem(
                icon: Icons.history,
                label: 'History',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/history',
                ),
              ),
              _gridMenuItem(
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/settings',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
