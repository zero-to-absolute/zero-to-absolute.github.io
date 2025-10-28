import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Инициализация приложения с подключением к Supabase
void main() async {
  // Инициализация Flutter перед запуском
  WidgetsFlutterBinding.ensureInitialized();
  
  // Подключение к Supabase
  await Supabase.initialize(
    url: 'https://zbptxyjdkybngjnvmygx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpicHR4eWpka3libmdqbnZteWd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwOTUxNjYsImV4cCI6MjA3NTY3MTE2Nn0.Z-AGcUCqURdQGNMKLSJCSyD9bDMUrqcPX-eBeuZ2s2w',
  );
  
  runApp(const MyApp());
}

// Глобальная переменная для доступа к Supabase
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Контроллеры для полей формы
  final _namingController = TextEditingController();
  final _statusController = TextEditingController();
  final _balanceController = TextEditingController();
  
  // Переменная для обновления FutureBuilder
  late Future<List<Map<String, dynamic>>> _dataFuture;
  
  // Показывать или скрывать форму добавления
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    // Загружаем данные при старте
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _namingController.dispose();
    _statusController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  // Метод для загрузки данных из Supabase
  Future<List<Map<String, dynamic>>> _loadData() async {
    try {
      // select() - получение данных из таблицы 'commerce'
      final response = await supabase
          .from('commerce')
          .select()
          .order('id', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Ошибка загрузки: $error');
      throw error;
    }
  }

  // Метод для добавления новой записи
  Future<void> _addItem() async {
    try {
      // insert() - добавление новых записей
      await supabase.from('commerce').insert({
        'naming': _namingController.text,
        'status': _statusController.text,
        'balance': double.tryParse(_balanceController.text) ?? 0,
      });

      // Очистка полей формы
      _namingController.clear();
      _statusController.clear();
      _balanceController.clear();
      
      // Обновление списка данных
      setState(() {
        _dataFuture = _loadData();
        _showAddForm = false;
      });
      
      // Показываем уведомление об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись добавлена!')),
      );
    } catch (error) {
      // Показываем ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Commerce App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Кнопка для показа формы добавления
            if (!_showAddForm)
              OutlinedButton.icon(
                onPressed: () => setState(() => _showAddForm = true),
                icon: const Icon(Icons.add),
                label: const Text('Добавить запись'),
              ),
            
            // Форма для добавления
            if (_showAddForm) _buildAddForm(),
            
            const SizedBox(height: 16),
            
            // FutureBuilder для отображения данных
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  // connectionState - состояние подключения
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Показываем загрузку
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Загрузка данных...'),
                        ],
                      ),
                    );
                  }
                  
                  // hasError - проверка наличия ошибки
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Ошибка: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }
                  
                  // hasData - проверка наличия данных
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Нет данных'),
                        ],
                      ),
                    );
                  }
                  
                  // Отображаем список данных
                  final items = snapshot.data!;
                  return Column(
                    children: [
                      // Статус загрузки
                      Card(
                        color: Colors.green.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Загружено записей: ${items.length}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Список
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  child: Text('${item['id']}'),
                                ),
                                title: Text(
                                  item['naming'] ?? 'Без названия',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Status: ${item['status']}\n'
                                  'Balance: ${item['balance']}',
                                ),
                                isThreeLine: true,
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item['status'] == 'millioner'
                                        ? Colors.green
                                        : Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['status'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Кнопка обновления данных
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _dataFuture = _loadData()),
        tooltip: 'Обновить данные',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // Виджет формы добавления
  Widget _buildAddForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Новая запись',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showAddForm = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _namingController,
              decoration: const InputDecoration(
                labelText: 'Naming',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Balance',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Добавить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
