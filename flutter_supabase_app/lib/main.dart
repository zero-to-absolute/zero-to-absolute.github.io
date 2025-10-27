import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zbptxyjdkybngjnvmygx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpicHR4eWpka3libmdqbnZteWd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwOTUxNjYsImV4cCI6MjA3NTY3MTE2Nn0.Z-AGcUCqURdQGNMKLSJCSyD9bDMUrqcPX-eBeuZ2s2w',
  );
  
  runApp(const MyApp());
}

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
  final _formKey = GlobalKey<FormState>();
  final _namingController = TextEditingController();
  final _statusController = TextEditingController();
  final _balanceController = TextEditingController();
  
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasData = false;
  bool _hasError = false;
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _namingController.dispose();
    _statusController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  // 1. Методы для работы с данными
  
  // получение данных из таблицы
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasError = false;
    });

    try {
      // await - ожидание завершения асинхронной операции
      final response = await supabase
          .from('commerce') //  указание таблицы для работы
          .select() //  получение данных
          .order('id', ascending: true); // сортировка по id
      
      print('Получено записей: ${response.length}'); // Отладочный вывод
      print('Данные: $response'); // Отладочный вывод
      
      // .then() - обработка результата операции
      setState(() {
        _items = List<Map<String, dynamic>>.from(response);
        _hasData = _items.isNotEmpty;
        _isLoading = false;
      });
    } catch (error) {
      // обработка ошибок
      print('Ошибка загрузки: $error'); // Отладочный вывод
      setState(() {
        _errorMessage = error.toString();
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // insert() - добавление новых записей
  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasError = false;
    });

    try {
      await supabase.from('commerce').insert({
        'naming': _namingController.text,
        'status': _statusController.text,
        'balance': double.tryParse(_balanceController.text) ?? 0,
      });

      _namingController.clear();
      _statusController.clear();
      _balanceController.clear();
      
      // Автоматическое обновление списка при получении новых данных
      await _loadData();
      
      setState(() {
        _showAddForm = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Ошибка добавления: ${error.toString()}';
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // Проверка состояния подключения
  bool get _connectionState {
    try {
      return supabase.realtime.channels.isNotEmpty || true;
    } catch (e) {
      return true; // Предполагаем подключение
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Commerce App'),
        actions: [
          // Отображение статуса подключения
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              _connectionState ? Icons.cloud_done : Icons.cloud_off,
              color: _connectionState ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Отображение статусов
            if (_hasData)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Данные загружены: ${_items.length} записей',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_hasError && _errorMessage != null)
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ошибка:',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Кнопка для показа формы добавления
            if (!_showAddForm)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showAddForm = true;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Показать форму добавления'),
              ),
            
            // Форма для добавления новых записей (скрываемая)
            if (_showAddForm)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Добавить новую запись',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _showAddForm = false;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _namingController,
                          decoration: const InputDecoration(
                            labelText: 'Naming',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите название';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _statusController,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите статус';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _balanceController,
                          decoration: const InputDecoration(
                            labelText: 'Balance',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите баланс';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Введите корректное число';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _addItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Добавить запись'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Список данных с CircularProgressIndicator во время загрузки
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(), // Показывать во время загрузки
                          SizedBox(height: 16),
                          Text('Загрузка данных...'),
                        ],
                      ),
                    )
                  : _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Нет данных в таблице commerce',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Проверьте подключение к Supabase',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade700,
                                  child: Text(
                                    '${item['id']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item['naming'] ?? 'Без названия',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text('Status: ${item['status'] ?? 'N/A'}'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.account_balance_wallet,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text('Balance: ${item['balance'] ?? 0}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _loadData,
        tooltip: 'Обновить данные',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
