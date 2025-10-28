import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutureBuilder Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilderDemo(),
    );
  }
}

class FutureBuilderDemo extends StatefulWidget {
  @override
  _FutureBuilderDemoState createState() => _FutureBuilderDemoState();
}

class _FutureBuilderDemoState extends State<FutureBuilderDemo> {
  // Создаём Future в initState, а не в build
  late Future<String> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchData();
  }

  // Асинхронная функция, имитирующая загрузку данных
  Future<String> fetchData() async {
    // Ждём 3 секунды (имитация сетевого запроса)
    await Future.delayed(Duration(seconds: 3));
    
    return 'Данные успешно загружены!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FutureBuilder Demo'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: _dataFuture,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            // Проверяем состояние подключения
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Пока данные загружаются
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
              // Если произошла ошибка
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
              // Если данные успешно получены
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
                ],
              );
            } else {
              // Неожиданное состояние
              return Text('Нет данных');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Перезапускаем загрузку данных
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
