import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'dart:async';

// ТОЧКА ВХОДА В ПРИЛОЖЕНИЕ
void main() async {
  // Инициализация Flutter перед запуском асинхронных операций
  WidgetsFlutterBinding.ensureInitialized();
  
  // Подключение к Supabase: указываем URL проекта и публичный ключ (anon key)
  await Supabase.initialize(
    url: 'https://zbptxyjdkybngjnvmygx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpicHR4eWpka3libmdqbnZteWd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwOTUxNjYsImV4cCI6MjA3NTY3MTE2Nn0.Z-AGcUCqURdQGNMKLSJCSyD9bDMUrqcPX-eBeuZ2s2w',
  );
  
  // Запуск приложения
  runApp(const MyApp());
}

// Глобальная переменная для быстрого доступа к клиенту Supabase
final supabase = Supabase.instance.client;

// ГЛАВНЫЙ ВИДЖЕТ ПРИЛОЖЕНИЯ
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // Использование Material Design 3
      ),
      home: const AuthGate(), // Стартовая страница - проверка авторизации
    );
  }
}

// ПРОВЕРКА АВТОРИЗАЦИИ (AuthGate)
// Этот виджет отслеживает состояние авторизации пользователя.
// Если пользователь авторизован - показывает HomePage,
// если нет - показывает страницу входа/регистрации (AuthPage).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder слушает изменения статуса авторизации в реальном времени
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange, // Поток событий авторизации
      builder: (context, snapshot) {
        // Если есть активная сессия - пользователь авторизован
        if (snapshot.hasData && snapshot.data!.session != null) {
          return const HomePage(); // Переходим на главную страницу
        }
        // Иначе показываем страницу входа
        return const AuthPage();
      },
    );
  }
}

// СТРАНИЦА ВХОДА И РЕГИСТРАЦИИ (AuthPage)
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход / Регистрация'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Ограничиваем ширину формы
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Иконка пользователя
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                
                // Название приложения
                const Text(
                  'Commerce App',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // Инструкция для пользователя
                const Text(
                  'Войдите или зарегистрируйтесь для продолжения',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Готовая форма входа/регистрации из пакета supabase_auth_ui
                SupaEmailAuth(
                  // redirectTo нужен для deep links (для мобильных приложений)
                  // Для веб-версии не используется (null)
                  redirectTo: kIsWeb ? null : 'io.mydomain.myapp://callback',
                  
                  // Callback при успешном входе
                  onSignInComplete: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Вход выполнен успешно!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  
                  // Callback при успешной регистрации
                  onSignUpComplete: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Регистрация завершена! Проверьте email для подтверждения.'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  
                  // Русская локализация текстов формы
                  localization: const SupaEmailAuthLocalization(
                    enterEmail: 'Введите ваш email',
                    enterPassword: 'Введите ваш пароль',
                    signIn: 'Войти',
                    signUp: 'Зарегистрироваться',
                    forgotPassword: 'Забыли пароль?',
                    dontHaveAccount: 'Нет аккаунта?',
                    haveAccount: 'Уже есть аккаунт?',
                    sendPasswordReset: 'Отправить сброс пароля',
                    backToSignIn: 'Назад к входу',
                    unexpectedError: 'Произошла непредвиденная ошибка',
                  ),
                  
                  // Дополнительное поле для имени пользователя (metadata)
                  metadataFields: [
                    MetaDataField(
                      prefixIcon: const Icon(Icons.person),
                      label: 'Имя пользователя',
                      key: 'username', // Ключ для сохранения в метаданных
                      validator: (val) {
                        // Валидация: поле обязательно для заполнения
                        if (val == null || val.isEmpty) {
                          return 'Введите имя пользователя';
                        }
                        return null; // Валидация пройдена
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ГЛАВНАЯ СТРАНИЦА ПРИЛОЖЕНИЯ (HomePage)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Контроллеры для текстовых полей (управляют вводом текста)
  final _namingController = TextEditingController();
  final _statusController = TextEditingController();
  final _balanceController = TextEditingController();
  
  // Флаг для показа/скрытия формы добавления записи
  bool _showAddForm = false;

  // Подписка на Realtime Stream (автообновление данных)
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    // При запуске страницы настраиваем автоматическое обновление данных
    _setupRealtimeStream();
  }

  @override
  void dispose() {
    // Очищаем ресурсы при закрытии страницы
    _namingController.dispose();
    _statusController.dispose();
    _balanceController.dispose();
    _realtimeSubscription?.cancel(); // Отменяем подписку на Stream
    super.dispose();
  }

  // НАСТРОЙКА REALTIME STREAM
  // Stream автоматически обновляет данные при любых изменениях в таблице
  void _setupRealtimeStream() {
    _realtimeSubscription = supabase
        .from('commerce') // Название таблицы в Supabase
        .stream(primaryKey: ['id']) // Указываем первичный ключ
        .order('id', ascending: true) // Сортировка по ID
        .listen(
          (List<Map<String, dynamic>> data) {
            // Обновляем UI при получении новых данных
            setState(() {});
          },
        );
  }

  // ФОРМА ДОБАВЛЕНИЯ НОВОЙ ЗАПИСИ
  Widget _buildInputForm() {
    return Card(
      elevation: 4, // Тень для карточки
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Новая запись',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Поле для названия
            TextField(
              controller: _namingController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 12),
            
            // Поле для статуса
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Статус',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
            ),
            const SizedBox(height: 12),
            
            // Поле для баланса (только цифры)
            TextField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Баланс',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              keyboardType: TextInputType.number, // Клавиатура с цифрами
            ),
          ],
        ),
      ),
    );
  }

  // ДОБАВЛЕНИЕ НОВОЙ ЗАПИСИ В БАЗУ ДАННЫХ
  Future<void> _addItem() async {
    try {
      // Отправляем данные в Supabase
      await supabase.from('commerce').insert({
        'naming': _namingController.text,
        'status': _statusController.text,
        'balance': double.tryParse(_balanceController.text) ?? 0, // Преобразуем в число
      });

      // Очищаем поля после успешного добавления
      _namingController.clear();
      _statusController.clear();
      _balanceController.clear();
      
      // Скрываем форму
      setState(() {
        _showAddForm = false;
      });
      
      // Показываем уведомление об успехе
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Запись добавлена!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      // Показываем уведомление об ошибке
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ВЫХОД ИЗ АККАУНТА
  Future<void> _signOut() async {
    await supabase.auth.signOut();
    // AuthGate автоматически перенаправит на страницу входа
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser; // Получаем текущего пользователя
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Commerce App'),
            // Показываем email пользователя
            if (user != null)
              Text(
                user.email ?? 'Пользователь',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          // Индикатор "LIVE" - показывает, что данные обновляются в реальном времени
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
          // Кнопка выхода
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Кнопка "Добавить запись" (если форма скрыта)
            if (!_showAddForm)
              OutlinedButton.icon(
                onPressed: () => setState(() => _showAddForm = true),
                icon: const Icon(Icons.add),
                label: const Text('Добавить запись'),
              ),
            
            // Форма добавления (если форма показана)
            if (_showAddForm) ...[
              _buildInputForm(),
              const SizedBox(height: 16),
              
              // Кнопка для отправки данных
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.send),
                  label: const Text('Добавить'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              // Кнопка отмены
              TextButton.icon(
                onPressed: () => setState(() => _showAddForm = false),
                icon: const Icon(Icons.close),
                label: const Text('Отмена'),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // СПИСОК ЗАПИСЕЙ ИЗ БАЗЫ ДАННЫХ
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('commerce')
                    .stream(primaryKey: ['id'])
                    .order('id', ascending: true),
                builder: (context, snapshot) {
                  // Показываем загрузку при ожидании данных
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Показываем сообщение об ошибке
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Ошибка: ${snapshot.error}'),
                    );
                  }
                  
                  // Показываем пустое состояние, если нет данных
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
                  
                  // Отображаем список записей
                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          
                          // ID записи в круглой иконке
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
                          
                          // Название записи
                          title: Text(
                            item['naming'] ?? 'Без названия',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          // Детали: статус и баланс
                          subtitle: Text(
                            'Статус: ${item['status']}\nБаланс: ${item['balance']}',
                          ),
                          isThreeLine: true,
                          
                          // Цветной бейдж со статусом
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}