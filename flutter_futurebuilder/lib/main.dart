import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    FutureBuilderDemo(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}

class FutureBuilderDemo extends StatefulWidget {
  @override
  _FutureBuilderDemoState createState() => _FutureBuilderDemoState();
}

class _FutureBuilderDemoState extends State<FutureBuilderDemo> {
  late Future<String> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchData();
  }

  Future<String> fetchData() async {
    await Future.delayed(Duration(seconds: 3));
    return 'Данные успешно загружены!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FutureBuilder Demo'),
        actions: [
          // Кнопка для перехода на DetailScreen
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              // Navigator.push() - переход на новый экран
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    title: 'Детальная информация',
                    message: 'Это экран с подробной информацией',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: _dataFuture,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Загрузка данных...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Ошибка: ${snapshot.error}',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            } else if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 20),
                  Text(
                    snapshot.data!,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  // Кнопка для перехода на другой экран
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: 'Успешная загрузка',
                            message: snapshot.data!,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Открыть детали'),
                  ),
                ],
              );
            } else {
              return Text('Нет данных');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _dataFuture = fetchData();
          });
        },
        child: Icon(Icons.refresh),
        tooltip: 'Перезагрузить',
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Иван Иванов',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'ivan@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            // Кнопка для редактирования профиля
            ElevatedButton(
              onPressed: () async {
                // Navigator.push() с ожиданием результата
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(),
                  ),
                );
                
                // Обработка результата после возврата
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Профиль обновлён: $result')),
                  );
                }
              },
              child: Text('Редактировать профиль'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Уведомления'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Переход на экран настроек уведомлений
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Тёмная тема'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Язык'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('О приложении'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Экран с деталями (пример Navigator.pop())
class DetailScreen extends StatelessWidget {
  final String title;
  final String message;

  const DetailScreen({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Кнопка для возврата назад
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.pop() - возврат на предыдущий экран
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Экран редактирования профиля
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Иван Иванов');
  final _emailController = TextEditingController(text: 'ivan@example.com');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать профиль'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigator.pop() с передачей данных обратно
                    Navigator.pop(context, _nameController.text);
                  },
                  child: Text('Сохранить'),
                ),
                OutlinedButton(
                  onPressed: () {
                    // Navigator.pop() без данных
                    Navigator.pop(context);
                  },
                  child: Text('Отмена'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Экран настроек уведомлений
class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки уведомлений'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Push-уведомления'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('Email-уведомления'),
            value: false,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('SMS-уведомления'),
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}

// Экран выбора языка
class LanguageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выбор языка'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Русский'),
            trailing: Icon(Icons.check, color: Colors.blue),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('English'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Español'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// Экран "О приложении"
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('О приложении'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apps, size: 100, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                'Navigation Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Версия 1.0.0'),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
