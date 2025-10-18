import 'package:flutter/material.dart';
import 'supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ItemsPage(),
    );
  }
}

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  bool _loading = false;
  String? _error;
  List _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await SupabaseConfig.client
          .from('users')
          .select('id, name, email, created_at')
          .order('created_at', ascending: false);
      setState(() {
        _items = resp as List;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _addItem() async {
    try {
      final name = 'Пользователь ${DateTime.now().millisecondsSinceEpoch}';
      final email = 'user${DateTime.now().millisecondsSinceEpoch}@example.com';
      await SupabaseConfig.client.from('users').insert({
        'name': name,
        'email': email,
      });
      await _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь добавлен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось добавить: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadItems,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              )
            : _items.isEmpty
                ? const Center(
                    child: Text('Нет данных. Добавьте пользователя.'),
                  )
                : RefreshIndicator(
                    onRefresh: _loadItems,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _items[index] as Map;
                        final id = item['id'];
                        final name = item['name']?.toString() ?? '(без имени)';
                        final email = item['email']?.toString() ?? '';
                        final createdAt = item['created_at']?.toString() ?? '';
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('$id'),
                          ),
                          title: Text(name),
                          subtitle: Text('$email\n$createdAt'),
                          isThreeLine: true,
                        );
                      },
                    ),
                  );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователи'),
        actions: [
          IconButton(
            onPressed: _loadItems,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}
