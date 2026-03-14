# Pemrograman Perangkat Bergerak

| Name                     | NRP        | Kelas   |
| ------------------------ | ---------- | ------- |
| Andi Nur Nabila Syalwani | 5025231104 | PPB (E) |

## Pertemuan 3

Pada pertemuan ke-3 kelas Pemrograman Perangkat Bergerak ini, materi yang diajarkan berkaitan dengan `widget` dan konsep `state` pada flutter.

Sebagai penjelasan singkat, `widget` merupakan semua komponen yang bisa kita lihat pada layar aplikasi, baik itu text, button, image, padding, alignment, dan keseluruhan struktur halaman. Sementara itu, `state` merujuk pada data atau informasi yang digunakan widget untuk menentukan bagaimana perilaku dan bentuk yang akan ditampilkannya.

Untuk memahami widget lebih lanjut, mari perhatikan gambar tampilan aplikasi di bawah ini:

[image my first app yang akan dijelaskan]

Pada gambar di atas, terdapat sebanyak 11 jenis widget berbeda. Berikut penjelasan masing masing widget dan contoh penggunaannya di dalam kode.

### MaterialApp

`MaterialApp` adalah widget yang digunakan sebagai root dari seluruh antarmuka aplikasi Flutter. Ini adalah widget yang pertama kali dibangun dalam hierarki widget, dan mengatur banyak konfigurasi yang mempengaruhi seluruh aplikasi.

`MaterialApp` ini digunakan pada line 13 di dalam `main.dart`:

```dart
return MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const RowColumnPage(),
);
```

### Scaffold

`Scaffold` adalah widget yang digunakan untuk membuat kerangka antarmuka umum yang mengikuti pedoman desain Material Design.

`Scaffold` ini digunakan pada line 32 di dalam `main.dart`:

```dart
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My First App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange[200],
        centerTitle: true,
      ),
      ...
    );
```

### AppBar

`AppBar` adalah widget yang merupakan bagian dari struktur `Scaffold` yang biasanya menampilkan judul aplikai, icon, atau action pada bagian atas halaman aplikasi.

AppBar ini digunakan pada line 33 di dalam `main.dart`:

```dart
      appBar: AppBar(
        title: const Text(
          'My First App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange[200],
        centerTitle: true,
      ),
```

### Text

`Text` adalah widget yang menampilkan informasi dalam bentuk tulisan.

`Text` ini digunakan pada line 33 di dalam `main.dart` dan berada di dalam struktur `AppBar`:

```dart
      appBar: AppBar(
        title: const Text(
          'My First App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange[200],
        centerTitle: true,
      ),
```

### Column

`Column` adalah widget yang mengatur alignment atau susunan widget-widget dalam aplikasi secara vertikal (kolom).

`Column` ini banyak digunakan di dalam `main.dart`. Berikut beberapa penggunaannya:

```dart
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
            ...
        ]
      )
```

```dart
children: <Widget>[
    Column(children: [Icon(Icons.food_bank), Text("Food")]),
    Column(children: [Icon(Icons.landscape), Text("Scenery")]),
    Column(children: [Icon(Icons.people), Text("People")]),
],
```

### Container

`Container` adalah widget yang digunakan untuk membuat visual elemen pada aplikasi. Container bisa diatur berdasarkan ukuran, padding, margin, tema, dan masih banyak lagi.

`Container` ini banyak digunakan di dalam `main.dart`. Berikut beberapa penggunaannya:

```dart
 children: <Widget>[
        Container(
        child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
            padding: EdgeInsets.all(20.0),
            color: Colors.lightBlue[100],
            child: Center(
                child: Image.network(
                'https://picsum.photos/200',
                fit: BoxFit.cover,
                width: 500,
                ),
            ),
            ),
        ),
        ),
        Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
        padding: EdgeInsets.all(20.0),
        color: Colors.pink[200],
        child: Text('What image is that', style: TextStyle(fontSize: 16)),
        ),
        Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.yellow[200],
        padding: EdgeInsets.all(20.0),
        margin: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Column(children: [Icon(Icons.food_bank), Text("Food")]),
            Column(children: [Icon(Icons.landscape), Text("Scenery")]),
            Column(children: [Icon(Icons.people), Text("People")]),
            ],
        ),
        ),
        CounterCard(),
    ],
```

### AspectRatio

`AspectRatio` adalah widget yang digunakan untuk mengatur rasio lebar dan tinggi dari child widget-nya.

`AspectRatio` ini digunakan pada line 46 di dalam `main.dart`:

```dart
  child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
        padding: EdgeInsets.all(20.0),
        color: Colors.lightBlue[100],
        child: Center(
            child: Image.network(
            'https://picsum.photos/200',
            fit: BoxFit.cover,
            width: 500,
            ),
        ),
        ),
    ),
```

### Center

`Center` adalah widget yang digunakan untuk menempatkan child widget-nya tepat di tengah-tengah ruang yang tersedia, baik secara horizontal maupun vertikal.

`Center` ini digunakan pada line 57 di dalam `main.dart`:

```dart
child: Center(
  child: Image.network(
    'https://picsum.photos/200',
    fit: BoxFit.cover,
    width: 500,
  ),
),
```

### Image

`Image` adalah widget yang digunakan untuk menampilkan gambar pada aplikasi. Dalam kasus ini, image yang digunakan menggunakan `image.network`

`Image` ini digunakan pada line 58 di dalam `main.dart`:

```dart
child: Image.network(
  'https://picsum.photos/200',
  fit: BoxFit.cover,
  width: 500,
),
```

### Row

`Row` adalah widget yang mengatur alignment atau susunan widget-widget dalam aplikasi secara horizontal (baris).

`Row` ini banyak digunakan di dalam main.dart. Berikut beberapa penggunaannya:

```dart
child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    Column(children: [Icon(Icons.food_bank), Text("Food")]),
    Column(children: [Icon(Icons.landscape), Text("Scenery")]),
    Column(children: [Icon(Icons.people), Text("People")]),
  ],
),
```

```dart
child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text("Counter here: $_counter", style: TextStyle(fontSize: 16)),
    Container(
      color: Colors.cyan[200],
      padding: EdgeInsets.all(5.0),
      child: IconButton(
        onPressed: _incrementCounter,
        icon: Icon(Icons.add, color: Colors.black, size: 16),
      ),
    ),
  ],
),
```

### IconButton

`IconButton` adalah widget yang menampilkan sebuah ikon yang dapat ditekan oleh pengguna untuk memicu suatu aksi atau fungsi tertentu dalam aplikasi.

`IconButton` ini digunakan di dalam CounterCard pada `main.dart`:

```dart
IconButton(
  onPressed: _incrementCounter,
  icon: Icon(Icons.add, color: Colors.black, size: 16),
),
```
