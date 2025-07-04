import 'package:flutter/material.dart';
import 'package:klube_cash_app/widgets/custom_app_bar.dart';
import 'package:klube_cash_app/widgets/custom_bottom_nav_bar.dart';
import 'package:klube_cash_app/services/auth_service.dart';
import 'package:klube_cash_app/models/transaction_history.dart';
import 'package:intl/intl.dart'; // Para formatar moeda e data

class StatementScreen extends StatefulWidget {
  const StatementScreen({Key? key}) : super(key: key); // Adicionado Key para boas práticas

  @override
  _StatementScreenState createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  final AuthService _authService = AuthService();
  final List<TransactionHistory> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _offset = 0;
  final int _limit = 5; // Limite de transações por carga
  bool _hasMore = true; // Indica se há mais transações para carregar

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      if (_offset == 0) _errorMessage = null; // Limpa erro apenas na primeira carga
    });

    try {
      final newTransactions = await _authService.getTransactionsHistory(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _transactions.addAll(newTransactions);
        _offset += newTransactions.length;
        _hasMore = newTransactions.length == _limit; // Se o número retornado for menor que o limite, não há mais
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().contains('Exception:') ? error.toString().replaceAll('Exception: ', '') : 'Erro inesperado: $error';
        _isLoading = false;
      });
      debugPrint('Erro ao carregar transações: $_errorMessage'); // Usar debugPrint
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatter para moeda
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    // Formatter para data
    final dateFormatter = DateFormat('dd/MM/yyyy \'às\' HH:mm');

    return Scaffold(
      appBar: const CustomAppBar(userInitial: 'K'), // Adicionado const, pode ser dinâmico
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0), // Adicionado const
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meu Histórico de',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                const Text( // Adicionado const
                  'Cashback',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                ),
                const SizedBox(height: 8), // Adicionado const
                Text(
                  'Acompanhe todo o dinheiro que você ganhou de volta.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16), // Adicionado const
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adicionado const
            child: Text(
              'Suas Compras e Cashback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ),
          Expanded(
            child: _transactions.isEmpty && _isLoading == false && _errorMessage == null
                ? const Center(child: Text('Nenhuma transação encontrada.')) // Adicionado const
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)), // Adicionado const
                            const SizedBox(height: 10), // Adicionado const
                            ElevatedButton(
                              onPressed: _loadTransactions,
                              child: const Text('Tentar Novamente'), // Adicionado const
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0), // Adicionado const
                        itemCount: _transactions.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _transactions.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0), // Adicionado const
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator()) // Adicionado const
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _hasMore ? _loadTransactions : null, // Adicionado const
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF7A00), // Adicionado const
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(vertical: 15), // Adicionado const
                                        ),
                                        child: const Text('Carregar mais'),
                                      ),
                                    ),
                            );
                          }

                          final transaction = _transactions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0), // Adicionado const
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0), // Adicionado const
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey[200],
                                        child: Icon(Icons.person, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 10), // Adicionado const
                                      Expanded(
                                        child: Text(
                                          transaction.lojaNome,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Adicionado const
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Adicionado const
                                        decoration: BoxDecoration(
                                          color: transaction.status == 'aprovado' ? Colors.green[100] : (transaction.status == 'pendente' ? Colors.orange[100] : Colors.red[100]),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          transaction.status == 'aprovado' ? 'Confirmado' : (transaction.status == 'pendente' ? 'Aguardando' : 'Cancelado'),
                                          style: TextStyle(
                                            color: transaction.status == 'aprovado' ? Colors.green[700] : (transaction.status == 'pendente' ? Colors.orange[700] : Colors.red[700]),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 25), // Adicionado const
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey), // Adicionado const
                                      const SizedBox(width: 5), // Adicionado const
                                      Text(
                                        dateFormatter.format(transaction.dataTransacao),
                                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10), // Adicionado const
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Valor da compra', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                          Text(
                                            currencyFormatter.format(transaction.valorTotal),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), // Adicionado const
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Saldo usado', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                          Text(
                                            '- ${currencyFormatter.format(transaction.valorUsado)}',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red[700]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10), // Adicionado const
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Você pagou', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                          Text(
                                            currencyFormatter.format(transaction.valorTotal - transaction.valorUsado),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), // Adicionado const
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Cashback ganho', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                          Text(
                                            // Usar valorCashbackCliente
                                            currencyFormatter.format(transaction.valorCashbackCliente),
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green[700]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15), // Adicionado const
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        debugPrint('Ver detalhes da transação ${transaction.id}'); // Usar debugPrint
                                      },
                                      icon: const Text('Ver detalhes', style: TextStyle(color: Color(0xFFFF7A00))), // Adicionado const
                                      label: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFF7A00)), // Adicionado const
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero, // Usar Size.zero para mínimo tamanho
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
          Padding(
            padding: const EdgeInsets.all(16.0), // Adicionado const
            child: Container(
              padding: const EdgeInsets.all(15), // Adicionado const
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 10), // Adicionado const
                  Expanded(
                    child: Text(
                      'Lembre-se: Você pode usar o saldo de cashback de cada loja apenas na própria loja onde foi gerado. É como ter um "crédito" exclusivo em cada estabelecimento.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar( // Adicionado const
        currentIndex: 2, // Marca "Extrato" como ativo
      ),
    );
  }
}