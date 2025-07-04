import 'package:flutter/material.dart';
import 'package:klube_cash_app/screens/statement_screen.dart';
import 'package:klube_cash_app/widgets/custom_app_bar.dart';
import 'package:klube_cash_app/widgets/custom_bottom_nav_bar.dart';
import 'package:klube_cash_app/services/auth_service.dart';
import 'package:klube_cash_app/models/user_balance.dart';
import 'package:klube_cash_app/models/transaction_history.dart';
import 'package:klube_cash_app/models/store.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserBalance? _userBalance;
  List<TransactionHistory> _recentTransactions = [];
  List<Store> _popularStores = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final balance = await _authService.getUserBalance();
      final recentTransactions = await _authService.getTransactionsHistory(limit: 3);
      final popularStores = await _authService.getPopularStores(limit: 5);

      setState(() {
        _userBalance = balance;
        _recentTransactions = recentTransactions;
        _popularStores = popularStores;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().contains('Exception:') ? error.toString().replaceAll('Exception: ', '') : 'Erro inesperado: $error';
        _isLoading = false;
      });
      debugPrint('Erro ao carregar dados do dashboard: $_errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    // Valor economizado e meta para a Jornada de Economia
    // Usamos totalCreditado do UserBalance como "Você já economizou"
    final double totalEconomizado = _userBalance?.totalCreditado ?? 0.0; 
    const double proximaMeta = 100.0; // Próxima meta: R$ 100
    final double progress = (totalEconomizado / proximaMeta).clamp(0.0, 1.0); // Garante que o progresso esteja entre 0 e 1

    return Scaffold(
      appBar: const CustomAppBar(userInitial: 'K'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erro ao carregar dados: $_errorMessage', style: const TextStyle(color: Colors.red, fontSize: 16)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card de Saldo Disponível
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7A00),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF7A00).withAlpha(77),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seu Saldo Disponível',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormatter.format(_userBalance?.saldoDisponivel ?? 0.0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Creditado',
                                        style: TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      Text(
                                        currencyFormatter.format(_userBalance?.totalCreditado ?? 0.0),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Total Usado',
                                        style: TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      Text(
                                        '- ${currencyFormatter.format(_userBalance?.totalUsado ?? 0.0)}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // NOVO: Sua Jornada de Economia
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white, // Fundo branco do card
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.show_chart, color: Color(0xFF673AB7)), // Ícone roxo do protótipo
                                  SizedBox(width: 8),
                                  Text(
                                    'Sua Jornada de Economia',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF424242), // Cor de texto quase preta
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Você já economizou',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575), // Cor de texto cinza
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                currencyFormatter.format(totalEconomizado),
                                style: const TextStyle(
                                  fontSize: 32, // Tamanho grande como no protótipo
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF673AB7), // Cor roxa do protótipo
                                ),
                              ),
                              const SizedBox(height: 15),
                              LinearProgressIndicator(
                                value: progress, // Progresso calculado
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF673AB7)), // Cor da barra de progresso roxa
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Próxima meta: ${currencyFormatter.format(proximaMeta)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Transações Recentes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transações Recentes',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                            TextButton(
                              onPressed: () {
                                debugPrint('Ver todas as transações');
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const StatementScreen())); // Adicionado const
                              },
                              child: const Text(
                                'Ver todas',
                                style: TextStyle(color: Color(0xFFFF7A00)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _recentTransactions.isEmpty
                            ? Center(child: Text('Nenhuma transação recente.', style: TextStyle(color: Colors.grey[600])))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _recentTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = _recentTransactions[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.store, color: Colors.white),
                                      ),
                                      title: Text(transaction.lojaNome, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                        '${dateFormatter.format(transaction.dataTransacao)} - ${currencyFormatter.format(transaction.valorTotal)}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            currencyFormatter.format(transaction.valorCashbackCliente),
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                                          ),
                                          Text(
                                            transaction.status == 'aprovado' ? 'Confirmado' : (transaction.status == 'pendente' ? 'Aguardando' : 'Cancelado'),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: transaction.status == 'aprovado' ? Colors.green : (transaction.status == 'pendente' ? Colors.orange : Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        debugPrint('Detalhes da transação: ${transaction.id}');
                                      },
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 30),

                        // Seção de Lojas Parceiras
                        Text(
                          'Lojas Parceiras',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 10),
                        _popularStores.isEmpty
                            ? Center(child: Text('Nenhuma loja encontrada.', style: TextStyle(color: Colors.grey[600])))
                            : SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _popularStores.length,
                                  itemBuilder: (context, index) {
                                    final store = _popularStores[index];
                                    return Card(
                                      margin: const EdgeInsets.only(right: 10),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      child: Container(
                                        width: 100,
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundColor: Colors.grey[200],
                                              // Se tiver logo URL: Image.network(store.logoUrl!),
                                              child: Text(store.nomeFantasia.substring(0,1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              store.nomeFantasia,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${store.porcentagemCashback.toStringAsFixed(0)}% CB',
                                              style: const TextStyle(fontSize: 10, color: Colors.green),
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
                  ),
                ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 0,
      ),
    );
  }

  String _userInitial() {
    return 'K';
  }
}