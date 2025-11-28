// ---------------------------------------------------
// lib/features/utils_menu/screens/converter_screen.dart
// ---------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Konverter Utilitas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.access_time), text: 'Waktu Rilis'),
              Tab(icon: Icon(Icons.attach_money), text: 'Mata Uang'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TimeConverterTab(),
            _CurrencyConverterTab(),
          ],
        ),
      ),
    );
  }
}

class _TimeConverterTab extends StatefulWidget {
  const _TimeConverterTab();

  @override
  State<_TimeConverterTab> createState() => _TimeConverterTabState();
}

class _TimeConverterTabState extends State<_TimeConverterTab> {
  TimeOfDay? _selectedTime; 
  String _wib = '...';
  String _wita = '...';
  String _wit = '...';
  String _london = '...';

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
        _convertTime();
      });
    }
  }

  void _convertTime() {
    if (_selectedTime == null) return;

    final jstLocation = tz.getLocation('Asia/Tokyo');
    final now = tz.TZDateTime.now(jstLocation);

    final jstTime = tz.TZDateTime(
      jstLocation,
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final wibLocation = tz.getLocation('Asia/Jakarta');
    final witaLocation = tz.getLocation('Asia/Makassar');
    final witLocation = tz.getLocation('Asia/Jayapura');
    final londonLocation = tz.getLocation('Europe/London');

    final formatter = DateFormat('HH:mm');
    _wib = formatter.format(tz.TZDateTime.from(jstTime, wibLocation));
    _wita = formatter.format(tz.TZDateTime.from(jstTime, witaLocation));
    _wit = formatter.format(tz.TZDateTime.from(jstTime, witLocation));
    _london = formatter.format(tz.TZDateTime.from(jstTime, londonLocation));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konversi Jadwal Rilis Anime (JST)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickTime,
            child: Text(
              _selectedTime == null
                  ? 'Pilih Waktu (JST)'
                  : 'Waktu JST: ${_selectedTime!.format(context)}',
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedTime != null) ...[
            Text('WIB (Jakarta): $_wib', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('WITA (Makassar): $_wita', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('WIT (Jayapura): $_wit', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('London (UK): $_london', style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }
}

class _CurrencyConverterTab extends StatefulWidget {
  const _CurrencyConverterTab();

  @override
  State<_CurrencyConverterTab> createState() => _CurrencyConverterTabState();
}

class _CurrencyConverterTabState extends State<_CurrencyConverterTab> {
  final _jpyController = TextEditingController();
  String _idr = '...';
  String _usd = '...';
  String _eur = '...';

  static const double _jpyToIdr = 104.50;
  static const double _jpyToUsd = 0.0064;
  static const double _jpyToEur = 0.0060;

  void _convertCurrency() {
    final double? jpy = double.tryParse(_jpyController.text);
    if (jpy == null) {
      setState(() {
        _idr = '...';
        _usd = '...';
        _eur = '...';
      });
      return;
    }
    
    // Format mata uang
    final idrFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final usdFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final eurFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    setState(() {
      _idr = idrFormatter.format(jpy * _jpyToIdr);
      _usd = usdFormatter.format(jpy * _jpyToUsd);
      _eur = eurFormatter.format(jpy * _jpyToEur);
    });
  }

  @override
  void dispose() {
    _jpyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konversi Harga Merchandise (JPY)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jpyController,
            decoration: const InputDecoration(
              labelText: 'Jumlah JPY (¥)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _convertCurrency(),
          ),
          const SizedBox(height: 24),
          Text('IDR (Rupiah): $_idr', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('USD (Dolar): $_usd', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('EUR (Euro): $_eur', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}