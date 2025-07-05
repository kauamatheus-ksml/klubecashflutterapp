// lib/screens/my_balance_screen.dart
import 'package:flutter/material.dart';
import 'package:klube_cash_app/widgets/custom_app_bar.dart';
import 'package:klube_cash_app/widgets/custom_bottom_nav_bar.dart';
import 'package:klube_cash_app/services/auth_service.dart';
import 'package:klube_cash_app/models/store_balance.dart'; // Importe o modelo
import 'package:intl/intl.dart'; // Para formatação de moeda

class MyBalanceScreen extends StatefulWidget {
  const MyBalanceScreen({Key? key}) : super(key: key);

  @override
  _MyBalanceScreenState createState() => _MyBalanceScreenState();
}

class _MyBalanceScreenState extends State<MyBalanceScreen> {
  final AuthService _authService = AuthService();
  List<StoreBalance> _storeBalances = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStoreBalances();
  }

  Future<void> _loadStoreBalances() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final balances = await _authService.getStoreBalances();
      setState(() {
        _storeBalances = balances;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().contains('Exception:') ? error.toString().replaceAll('Exception: ', '') : 'Erro inesperado: $error';
        _isLoading = false;
      });
      debugPrint('Erro ao carregar saldos por loja: $_errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: const CustomAppBar(userInitial: 'K'), // Pode ser dinâmico
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldos por Loja',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  'Acompanhe seu cashback disponível em cada loja parceira.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadStoreBalances,
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : _storeBalances.isEmpty
                        ? const Center(child: Text('Nenhum saldo encontrado por loja.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _storeBalances.length,
                            itemBuilder: (context, index) {
                              final balance = _storeBalances[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            child: Text(balance.lojaNome.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              balance.lojaNome,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 25),
                                      _buildBalanceRow('Saldo Disponível:', balance.saldoDisponivel, currencyFormatter, Colors.green[700]),
                                      _buildBalanceRow('Total Creditado:', balance.totalCreditado, currencyFormatter, Colors.blue[700]),
                                      _buildBalanceRow('Total Usado:', balance.totalUsado, currencyFormatter, Colors.red[700]),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            debugPrint('Ver extrato da loja ${balance.lojaNome}');
                                            // TODO: Navegar para o extrato filtrado por loja
                                          },
                                          icon: const Text('Ver extrato da loja', style: TextStyle(color: Color(0xFFFF7A00))),
                                          label: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFF7A00)),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 1, // Marca "Meu Saldo" como ativo
      ),
    );
  }

  Widget _buildBalanceRow(String label, double value, NumberFormat formatter, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Text(
            formatter.format(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}