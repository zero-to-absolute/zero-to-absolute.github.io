import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';


// Инициализация приложения с подключением к Supabase
void main() async {
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
  // Контроллеры для полей формы
  final _namingController = TextEditingController();
  final _statusController = TextEditingController();
  final _balanceController = TextEditingController();
  
  // Показывать или скрывать форму добавления
  bool _showAddForm = false;

  late Future<List<Map<String, dynamic>>> _dataFuture;

  // Realtime Stream для автоматического обновления
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
    _setupRealtimeStream();
  }


  @override
  void dispose() {
    _namingController.dispose();
    _statusController.dispose();
    _balanceController.dispose();
    _realtimeSubscription?.cancel();
    super.dispose();
  }


  // Метод загрузки данных
  Future<List<Map<String, dynamic>>> _loadData() async {
    try {
      print('Загружаем данные через FutureBuilder...');
      
      final response = await supabase
          .from('commerce')
          .select()
          .order('id', ascending: true);
      
      print('Данные загружены через FutureBuilder');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Ошибка загрузки: $error');
      throw error;
    }
  }


  // Настройка Realtime Stream
  void _setupRealtimeStream() {
    print('Настройка Realtime Stream для таблицы commerce...');
    
    _realtimeSubscription = supabase
        .from('commerce')
        .stream(primaryKey: ['id'])
        .order('id', ascending: true)
        .listen(
          (List<Map<String, dynamic>> data) {
            print('Получены данные из Stream: ${data.length} записей');
            
            setState(() {
              _items = data;
              _isLoading = false;
              _errorMessage = null;
              _dataFuture = Future.value(data);
            });
          },
          onError: (error) {
            print('Ошибка Stream: $error');
            setState(() {
              _errorMessage = error.toString();
              _isLoading = false;
            });
          },
        );
    
    print('Realtime Stream активирован');
  }


  // Создать поле ввода сообщения с обработкой изменений (onChanged)
  Widget _buildInputField() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Поле ввода с обработкой изменений',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _namingController,
              decoration: const InputDecoration(
                labelText: 'Naming',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              onChanged: (value) {
                print('Поле "Naming" изменено: $value');
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              onChanged: (value) {
                print('Поле "Status" изменено: $value');
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Balance',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                print('Поле "Balance" изменено: $value');
              },
            ),
          ],
        ),
      ),
    );
  }


  // Реализовать отправку сообщения через insert в базу данных
  Future<void> _addItem() async {
    try {
      print('Отправка данных в базу через insert...');
      
      await supabase.from('commerce').insert({
        'naming': _namingController.text,
        'status': _statusController.text,
        'balance': double.tryParse(_balanceController.text) ?? 0,
      });

      _namingController.clear();
      _statusController.clear();
      _balanceController.clear();
      
      setState(() {
        _showAddForm = false;
      });
      
      print('Данные успешно добавлены');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запись добавлена! Stream автоматически обновит список'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (error) {
      print('Ошибка добавления: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Commerce App'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Realtime Stream'),
                  content: const Text(
                    'Используется Supabase Realtime Stream:\n\n'
                    'supabase.from(\'commerce\')\n'
                    '  .stream(primaryKey: [\'id\'])\n'
                    '  .listen(...)\n\n'
                    'Данные обновляются автоматически без ручного обновления'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.stream, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Realtime Stream активен - данные обновляются автоматически',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            if (!_showAddForm)
              OutlinedButton.icon(
                onPressed: () => setState(() => _showAddForm = true),
                icon: const Icon(Icons.add),
                label: const Text('Добавить запись'),
              ),
            
            if (_showAddForm) ...[
              _buildInputField(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.send),
                  label: const Text('Добавить запись'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _showAddForm = false),
                icon: const Icon(Icons.close),
                label: const Text('Отмена'),
              ),
            ],
            
            const SizedBox(height: 16),
            
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Загрузка через FutureBuilder...'),
                        ],
                      ),
                    );
                  }
                  
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
                  
                  final items = snapshot.data!;
                  return Column(
                    children: [
                      Card(
                        color: Colors.green.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'FutureBuilder + Stream: ${items.length} записей',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          children: List.generate(items.length, (index) {
                            final item = items[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    '${item['id']}',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
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
                                subtitle: Text(
                                  'Status: ${item['status']}\n'
                                  'Balance: ${item['balance']}\n'
                                  'FutureBuilder + Stream index[${index}]',
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
                          }),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stream обновляется автоматически'),
              backgroundColor: Colors.blue,
            ),
          );
        },
        tooltip: 'Stream обновляется автоматически',
        icon: const Icon(Icons.stream),
        label: const Text('Auto'),
      ),
    );
  }
}
