import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const FinanceHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FinanceHomePage extends StatefulWidget {
  const FinanceHomePage({super.key});

  @override
  State<FinanceHomePage> createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends State<FinanceHomePage> {
  late final ScrollController _dateScrollController;

  @override
  void initState() {
    super.initState();
    _dateScrollController = ScrollController();
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя секция с градиентом
            Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF81C784),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок с аватаром
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Payday in a week',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Баланс
                    const Text(
                      'Total balance to spend',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$5785.55',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Основной контент
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Planning Ahead секция
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Planning Ahead',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          '-\$540.52',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Три карточки планирования
                    Row(
                      children: [
                        Expanded(
                          child: _buildPlanningCard(
                            icon: Icons.trending_up,
                            color: Colors.blue,
                            amount: '-150.52',
                            description: 'In a 2 days',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildPlanningCard(
                            icon: Icons.account_balance_wallet,
                            color: Colors.green,
                            amount: '-250.52',
                            description: 'In a 2 days',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildPlanningCard(
                            icon: Icons.restaurant,
                            color: Colors.red,
                            amount: '-138.48',
                            description: 'In a 2 days',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Last Month Expense секция
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Last Month Expense',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              '-\$1800.50',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // График расходов по дням
                    // График расходов по дням с горизонтальным скроллом
// График расходов по дням с ListView.builder
Container(
  height: 80,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    itemCount: 31, // Все дни месяца
    itemBuilder: (context, index) {
      final day = (index + 1).toString();
      final isActive = index == 7; // 8-й день активен
      
      return Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: isActive ? 30 : 20, // Активный столбец выше
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.blue : Colors.black87,
              ),
            ),
            Text(
              'MAR',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    },
  ),
),

                    const SizedBox(height: 25),
                    
                    // Список транзакций
                    _buildTransactionItem(
                      icon: Icons.work,
                      color: Colors.blue,
                      title: 'Craftwork',
                      amount: '-150.52',
                    ),
                    const SizedBox(height: 15),
                    _buildTransactionItem(
                      icon: Icons.psychology,
                      color: Colors.red,
                      title: 'Focus Lab',
                      amount: '-150.52',
                    ),
                  ],
                ),
              ),
            ),
            
            // Нижняя навигация
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.credit_card, 'Spend', true),
                  _buildNavItem(Icons.favorite_border, 'Save', false),
                  _buildNavItem(Icons.schedule, 'Schedule', false),
                  _buildNavItem(Icons.menu, 'Menu', false),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPlanningCard({
    required IconData icon,
    required Color color,
    required String amount,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey.shade400,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
